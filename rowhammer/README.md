# RowHammer Protection Module (TRR)

This project implements a **RowHammer mitigation mechanism** using **SystemVerilog**.  
The design uses a **Target Row Refresh (TRR)** technique to detect frequent row
activations in DRAM and trigger refresh operations to prevent data corruption.

## Description
RowHammer is a hardware vulnerability where repeated activation of a DRAM row
can cause bit flips in adjacent rows. This module monitors memory access
patterns and activates protective refresh mechanisms when abnormal row access
is detected.

## Files
- `rowhammer.sv` – SystemVerilog implementation of the RowHammer mitigation logic
- `rowhammer_tb.sv` – Testbench used to verify detection and protection behavior

## Tools Used
- SystemVerilog
- Xilinx Vivado (Simulation)

## Skills Demonstrated

- Computer Architecture
- Memory Security
- RowHammer Mitigation
- RTL Design
- Digital Design Verification
