# RowHammer Protection Module (TRR)

**SystemVerilog | DRAM Architecture | Memory Security | RTL Design**

## Project Overview

This project implements a **RowHammer detection and mitigation mechanism** using SystemVerilog, based on the concept of **Target Row Refresh (TRR)**.

RowHammer is a DRAM vulnerability where repeated activation of a memory row can cause unintended bit flips in adjacent rows. The proposed design monitors row activation frequency, detects excessive accesses, and generates targeted refresh requests to support memory reliability.

## System Architecture & Implementation

The design consists of the following functional blocks:

| Component | Function |
|---|---|
| Row Address Decoder | Extracts row indices from memory addresses |
| Activation Counters | Tracks the number of accesses to individual DRAM rows |
| Threshold Detector | Detects excessive row activation |
| Refresh Controller | Generates targeted refresh requests |
| Scrubbing Logic | Initiates periodic background scrub requests |

### Working Principle

1. Memory accesses are monitored through `mem_addr` and `mem_valid`.
2. Individual row activation counters track access frequency.
3. When a counter reaches the configured `THRESHOLD`, a refresh request is generated.
4. The module selects the next row (`hammered_row + 1`) as the refresh target.
5. A separate timer generates periodic background scrub requests.

## Design Configuration

| Parameter | Default Value |
|---|---|
| Address Width | 32 bits |
| Row Width | 16 bits |
| Monitored Rows | 65,536 |
| Activation Threshold | 2 |
| Scrub Interval | 5 cycles |

These values are configured for functional demonstration and simulation.

## Verification & Testing

A dedicated SystemVerilog testbench (`rowhammer_tb.sv`) exercises the design using:

- Reset and initialization sequences
- Repeated accesses to the same memory row
- Multiple-row activation patterns
- Refresh-trigger monitoring
- Periodic scrubbing behavior
- Randomized memory-access sequences

The testbench supports waveform analysis and simulation-based observation of the module's behavior.

## Project Structure

```text
RowHammer-Protection/
├── rowhammer.sv       # Detection and mitigation RTL
├── rowhammer_tb.sv    # Verification testbench
└── README.md          # Project documentation
```

## Tools & Technical Skills

**Tools:** SystemVerilog, Xilinx Vivado

**Concepts:** RTL Design, Computer Architecture, DRAM Reliability, Hardware Security, Functional Verification, Counter-Based Detection

## Limitations & Future Scope

The implementation demonstrates refresh-request generation in simulation; it is not integrated with a physical DRAM controller.

Future enhancements include dual-adjacent-row refresh, realistic DRAM timing constraints, optimized counter storage, and extended verification.

## Author

**Ritul Mahajan**  
M.Sc. Electrical Engineering and Embedded Systems  
Hochschule Ravensburg-Weingarten, Germany

## License & Attribution

Original copyright notices and applicable licensing conditions must be preserved. Third-party contributions should be acknowledged.
