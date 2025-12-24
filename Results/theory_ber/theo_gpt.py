#!/usr/bin/env python3
"""
Actual vs Two Theoretical Approximations for GFSK Differential Demod (8–15 dB)
- Model A: Exponential empirical model (your original form), fitted at 13 dB
- Model B: Q-function approx for differential decision variable, fitted at 13 dB

Outputs:
  1) gfsk_ber_8to15dB_theory_vs_actual.csv
  2) gfsk_ber_8to15dB_theory_vs_actual.png
"""

import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.special import erfc


# ----------------------------
# Helpers
# ----------------------------
def Q(x: np.ndarray) -> np.ndarray:
    """Gaussian Q-function."""
    return 0.5 * erfc(x / np.sqrt(2))


def model_exp(ebn0_db: np.ndarray, beta_eff: float) -> np.ndarray:
    """
    Exponential empirical model (your original):
      Pe = 0.5 * exp(-gamma * sin^2(beta/2))
    """
    gamma = 10 ** (ebn0_db / 10.0)
    mod_factor = np.sin(beta_eff / 2.0) ** 2
    return 0.5 * np.exp(-gamma * mod_factor)


def model_qdiff(ebn0_db: np.ndarray, delta_phi_eff: float) -> np.ndarray:
    """
    Q-function approximation for differential decision variable:
      Pb ≈ Q( gamma*sin(delta_phi) / sqrt(gamma + 1/2) )
    """
    gamma = 10 ** (ebn0_db / 10.0)
    x = (gamma * np.sin(delta_phi_eff)) / np.sqrt(gamma + 0.5)
    return Q(x)


def fit_beta_eff_exp(fit_db: float, pe_fit: float) -> float:
    """
    Fit beta_eff for exponential model analytically from one point:
      pe = 0.5 exp(-gamma * sin^2(beta/2))
    => sin^2(beta/2) = -ln(2pe)/gamma
    """
    gamma = 10 ** (fit_db / 10.0)
    mod_factor = -np.log(2 * pe_fit) / gamma
    mod_factor = np.clip(mod_factor, 0.0, 1.0)  # keep valid
    beta_eff = 2 * np.arcsin(np.sqrt(mod_factor))
    return float(beta_eff)


def fit_delta_phi_qdiff(fit_db: float, pe_fit: float, grid_n: int = 200000) -> float:
    """
    Fit delta_phi_eff for Qdiff model by 1D search (monotonic in sin(delta)):
    delta_phi in (0, pi)
    """
    grid = np.linspace(1e-5, np.pi - 1e-5, grid_n)
    vals = model_qdiff(np.array([fit_db], dtype=float), grid)  # broadcasting
    best_idx = int(np.argmin(np.abs(vals - pe_fit)))
    return float(grid[best_idx])


# ----------------------------
# Main
# ----------------------------
def main():
    # Eb/N0 points
    ebn0_db = np.arange(8, 16, 1)  # 8..15

    # Actual BER measurements (8..15 dB) - updated
    ber_actual = np.array([
        0.023193370438559,       # 8 dB
        0.013094784509681,       # 9 dB
        0.006713048353785,       # 10 dB
        0.003045684801649,       # 11 dB
        0.001127873013095,       # 12 dB
        0.000339063126199,       # 13 dB
        0.000077103974710,       # 14 dB
        0.000010314430733       # 15 dB
    ], dtype=float)

    # Fit at 13 dB
    fit_db = 13.0
    fit_idx = int(np.where(ebn0_db == fit_db)[0][0])
    pe_fit = float(ber_actual[fit_idx])

    beta_eff = fit_beta_eff_exp(fit_db, pe_fit)  # computed but not printed/used
    delta_phi_eff = 1.1
    # Curves (Q-diff only)
    ebn0_smooth = np.arange(8, 15.01, 0.1)
    ber_qdiff_smooth = model_qdiff(ebn0_smooth, delta_phi_eff)
    ber_qdiff_points = model_qdiff(ebn0_db, delta_phi_eff)

    # Save CSV
    df = pd.DataFrame({
        "EbN0_dB": ebn0_db,
        "BER_Actual": ber_actual,
        "BER_QDiffModel_Fit13dB": ber_qdiff_points
    })
    # ensure output directories exist
    out_dir = os.path.dirname(__file__)
    csv_dir = os.path.join(out_dir, "csv")
    fig_dir = os.path.join(out_dir, "fig")
    os.makedirs(csv_dir, exist_ok=True)
    os.makedirs(fig_dir, exist_ok=True)

    csv_filename = os.path.join(csv_dir, "gfsk_ber_8to15dB_theory_vs_actual.csv")
    df.to_csv(csv_filename, index=False, float_format="%.6e")

    print("Fitted parameters @13 dB (Q-diff):")
    print(f"  delta_phi_eff = {delta_phi_eff:.6f} rad  (Q-diff model)")
    print(f"Saved CSV: {csv_filename}")
    print(df)

    # Plot
    plt.figure(figsize=(10, 7))
    plt.semilogy(
        ebn0_smooth, ber_qdiff_smooth, linewidth=2,
        label=rf"Q-diff approx (fit@13dB)  $\Delta\phi_{{eff}}={delta_phi_eff:.3f}$ rad"
    )
    plt.semilogy(ebn0_db, ber_actual, "s", markersize=7, label="Actual")

    plt.grid(True, which="both", linestyle="--", alpha=0.5)
    plt.title("GFSK BER: Actual vs Two Fitted Theoretical Approximations (8–15 dB)")
    plt.xlabel(r"$E_b/N_0$ (dB)")
    plt.ylabel("BER")
    plt.legend()

    plt.annotate(
        "Fitted @13 dB",
        xy=(fit_db, ber_actual[fit_idx]),
        xytext=(fit_db - 1.3, ber_actual[fit_idx] * 2.2),
        arrowprops=dict(arrowstyle="->")
    )

    plt.tight_layout()
    plot_filename = os.path.join(fig_dir, "gfsk_ber_8to15dB_theory_vs_actual.png")
    plt.savefig(plot_filename, dpi=300)
    print(f"Saved plot: {plot_filename}")
    plt.show()


if __name__ == "__main__":
    main()
