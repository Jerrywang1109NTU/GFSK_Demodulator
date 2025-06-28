
# GFSK Demodulator

This repository contains MATLAB implementations for simulating and analyzing Gaussian Frequency Shift Keying (GFSK) demodulation. Both floating-point and fixed-point models are provided for comparison and research purposes.

## 📁 Repository Structure

```
.
├── GFSK_MTLB_fixed/       # Fixed-point MATLAB simulation
└── GFSK_MTLB_float/       # Floating-point MATLAB simulation
```

## 🚀 Getting Started

### Prerequisites

- MATLAB R2016a or later
- Signal Processing Toolbox (if required)

### Running Simulations

1. Clone this repository:

```bash
git clone https://github.com/Jerrywang1109NTU/GFSK_Demodulator.git
```

2. Open MATLAB.

3. Navigate to the desired simulation directory:

For floating-point simulation:

```matlab
cd GFSK_MTLB_float
run main.m
```

For fixed-point simulation:

```matlab
cd GFSK_MTLB_fixed
run main.m
```

4. View the BER performance plots and simulation results.

## 📊 Features

- End-to-end GFSK modulation and demodulation flow.
- Support for AWGN channel simulation and BER performance evaluation.
- Fixed-point model for hardware-oriented analysis.
- Floating-point model for algorithm benchmarking.

## 📝 Notes

- The fixed-point simulation approximates hardware constraints and is useful for pre-RTL verification.
- The floating-point version serves as the golden reference for performance comparison.

## 📄 License

This project is released under the MIT License. See the [LICENSE](LICENSE) file for details.

## 📚 Citation

If you use this project in your research, please cite:

```bibtex
@mastersthesis{Wang2024GFSK,
  author  = {Wang, Runyan},
  title   = {{Design and Implementation of GFSK Demodulation Algorithm on FPGA}},
  school  = {Beijing Institute of Technology},
  year    = {2024},
  note    = {Bachelor's Thesis}
}
```
