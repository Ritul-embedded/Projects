# RISC-V Floating Point Unit (FPU)

This project implements **floating-point instruction support for a RISC-V processor**
using **SystemVerilog**. The design includes separate modules for instruction decoding,
floating-point arithmetic operations, and register handling.

## Description
The floating-point unit extends the RISC-V processor to support **IEEE-754 single
precision floating-point operations**. The architecture is modular, where different
components such as the instruction decoder, floating-point ALU, and register file
are implemented as independent SystemVerilog modules and integrated at the top level.

## Modules
- `InstrDec.sv` – Instruction decoder for floating-point instructions
- `FPALU.sv` – Floating-point arithmetic unit (add, sub, mul, div)
- `FPRegFile.sv` – Floating-point register file
- `RV64Top.sv` – Top-level integration module
- `testbench.sv` – Testbench for simulation and verification

## Features
- Support for floating-point arithmetic operations
- Modular architecture for easy integration
- Testbench-based verification

## Tools Used
- SystemVerilog
- Xilinx Vivado (Simulation)

## Skills Demonstrated

- IEEE-754 Floating Point Arithmetic
- RISC-V ISA Extension
- FPGA Design
- RTL Design
- Digital Design Verification
