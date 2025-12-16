#!/usr/bin/env python3
"""
Theoretical BER curve for the multi-sample differential GFSK detector.

Formula (high-SNR approximation):
    Pe ≈ Q( sqrt( 2 * Eb/N0 * G_eps * cos(Delta_phi_res) * N_d * kappa ) )
where
    G_eps = cos^2(pi * eps / N_T)   (timing error loss, eps in samples)
    Delta_phi_res: residual CFO phase per symbol (radians), typically ~0
    N_d: number of paired samples averaged in the differential detector
    kappa: shaping factor (<1) from Gaussian filter smoothing; used here as 1.0

This script sweeps Eb/N0 and plots the theoretical Pe curve.
You can tweak N_d, eps, Delta_phi_res, N_T, and kappa to match your setup.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from scipy.special import erfc


def qfunc(x: np.ndarray) -> np.ndarray:
    """Q-function using erfc."""
    return 0.5 * erfc(x / np.sqrt(2.0))


def ber_curve(
    ebn0_db: np.ndarray,
    n_d: int = 7,
    n_t: int = 20,
    eps_samp: float = 0.0,
    delta_phi_res: float = 0.0,
    kappa: float = 1.0,
) -> np.ndarray:
    """
    Compute theoretical BER for given parameters.

    Args:
        ebn0_db: array of Eb/N0 in dB
        n_d: number of differential sample pairs averaged
        n_t: samples per symbol (for timing-loss factor)
        eps_samp: timing offset in samples (0 means perfect)
        delta_phi_res: residual CFO-induced phase per symbol [rad]
        kappa: shaping factor from GFSK pulse (<=1), use 1.0 if unknown
    """
    ebn0_lin = 10 ** (ebn0_db / 10.0)
    g_eps = math.cos(math.pi * eps_samp / n_t) ** 2
    cfo_loss = math.cos(delta_phi_res)
    eff_snr = 2.0 * ebn0_lin * g_eps * cfo_loss * n_d * kappa
    # Guard against negative due to cos() if delta_phi_res is large
    eff_snr = np.maximum(eff_snr, 0.0)
    return 0.5 * erfc(np.sqrt(eff_snr / 2.0))


def main():
    # Typical defaults from your setup
    ebn0_db = np.linspace(8, 20, 49)  # 0.25 dB step
    n_t = 20  # samples per symbol
    n_d = 7   # multi-sample pairs (adjust to match RTL)
    eps_samp = 0.0      # timing error in samples
    delta_phi_res = 0.0 # residual CFO phase per symbol (rad)
    kappa = 1.0         # Gaussian shaping factor (<1). Set ~0.9 if desired.

    pe = ber_curve(
        ebn0_db,
        n_d=n_d,
        n_t=n_t,
        eps_samp=eps_samp,
        delta_phi_res=delta_phi_res,
        kappa=kappa,
    )

    plt.semilogy(ebn0_db, pe, label="Theory (Nd=%d)" % n_d)
    plt.grid(True, which="both")
    plt.xlabel(r"$E_b/N_0$ (dB)")
    plt.ylabel("BER")
    plt.ylim(1e-7, 1)
    plt.xlim(8, 20)
    plt.legend()
    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    main()

