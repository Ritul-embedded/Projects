# RISC-V-Oriented 64-bit Arithmetic Logic Unit (ALU)

**RTL design and simulation project | SystemVerilog | Xilinx Vivado**

## Project overview

This project explores the design of a **parameterized, combinational Arithmetic Logic Unit (ALU)** inspired by operations used in the RISC-V instruction set architecture. The ALU accepts two operands and a selection code, computes the requested operation, and exposes the result along with status signals. The provided implementation uses **64-bit operands by default** and a **6-bit operation selector**.

The repository includes the RTL module and a SystemVerilog testbench for functional simulation. It is a standalone ALU exercise, **not a complete RISC-V processor or a verified ISA-compliant CPU**.

## Objectives

- Describe a configurable ALU in synthesizable-style SystemVerilog.
- Implement arithmetic, Boolean logic, shifts, and signed/unsigned comparisons.
- Explore RISC-V-inspired immediate, load-data formatting, branch, and jump operations.
- Generate result and status outputs from combinational logic.
- Exercise operation selections using a dedicated simulation testbench.
- Practice an RTL development and verification workflow in Xilinx Vivado.

## Tools and technologies

| Area | Technology |
| --- | --- |
| Hardware description language | SystemVerilog |
| Development and simulation environment | Xilinx Vivado |
| Default operand/result width | 64 bits |
| ALU operation select width | 6 bits |
| Verification approach | SystemVerilog testbench with expected-result checks |

## Repository files

```text
RISC-V-64bit-ALU/
├── ALU_MOD.sv       # Combinational ALU RTL (module: alumod)
├── ALU_MOD_TB.sv    # Testbench (module: tb_alumod)
└── README.md        # Project documentation
```

Vivado-generated caches, runs, and simulation output directories are omitted from this compact GitHub package because they can be regenerated locally.

## ALU architecture

The ALU has two operand inputs (`data01_i`, `data02_i`) and a selector (`aluSel_i`). Arithmetic, logic, shift, comparison, and formatting expressions are evaluated in RTL, and a combinational `case` statement selects the result. Status outputs are derived from the result and internal arithmetic signals.

```text
           data01_i (64 bits) ──────┐
                                    ├──> Arithmetic / Logic / Shift /
           data02_i (64 bits) ──────┘     Compare / Data-format logic
                                                   │
           aluSel_i (6 bits) ───────────> Selection mux
                                                   │
                                               aluResult_o
                                                   │
                                         Result / status outputs
```

### Module interface

| Signal | Direction | Purpose |
| --- | --- | --- |
| `data01_i` | Input | First operand |
| `data02_i` | Input | Second operand / immediate-like input |
| `aluSel_i` | Input | Selects the ALU operation |
| `aluResult_o` | Output | Selected operation result |
| `aluZero_o` | Output | High when the selected result equals zero |
| `aluNega_o` | Output | Most significant bit of the selected result |
| `aluCarr_o` | Output | Carry-related signal from the addition expression |
| `aluOver_o` | Output | Overflow-related signal as currently coded; see limitations |

The source defines parameters `reg_width = 64` and `aluselrv_width = 6`. Some operations explicitly use 64-bit extension constants or fixed bit slices, so changing the data width requires further review.

## Supported operation groups

The `aluSel_i` values below refer to **internal selector codes**, not RISC-V instruction encodings.

| Selector | Operation | Description |
| --- | --- | --- |
| 0–1 | ADD, SUB | Addition and subtraction |
| 2–4 | AND, OR, XOR | Bitwise Boolean operations |
| 5–7 | SLL, SRL, SRA | Logical left/right and arithmetic right shifts |
| 8–9 | SLT, SLTU | Signed and unsigned less-than comparisons |
| 10–16 | ADDI, SLLI, SRLI, SRAI, XORI, ORI, ANDI | Immediate-style variants |
| 17 | AUIPC | PC-relative-style arithmetic expression |
| 18–24 | LB, LH, LW, LBU, LHU, LWU, LD | Sign/zero extension and load-data formatting |
| 25–30 | ADDIW, SLLIW, SRLIW, SRAIW, ADDW, SUBW | Word-operation-inspired selections |
| 31–36 | BEQ, BNE, BLT, BGE, BLTU, BGEU | Branch-condition comparisons |
| 37 | Jump target | Jump-related address expression |
| 38–39 | SLTI, SLTIU | Immediate-style comparisons |
| 40–42 | SB, SH, SW | Store-data passthrough selections |
| 43 | JALR | Jump-register-related address expression |
| 44 | SD | Store-data passthrough selection |

**Implementation note:** These are operations represented in the supplied RTL. Some are simplified relative to full RISC-V ISA semantics; for example, load selections format operand bits rather than accessing memory, and branch selections output Boolean comparison results rather than updating a program counter.

## Design implementation

### Arithmetic and Boolean logic

The RTL uses continuous assignments to form intermediate arithmetic and shift results. Boolean operations are selected directly in the combinational `case` block. The result path is intended to respond to input changes without a clock.

### Shifts and comparisons

Shift expressions use the lower six bits of the second operand as the shift amount. Signed comparison and arithmetic-right-shift operations use signed interpretations of the operands; unsigned comparisons use unsigned operand values.

### Data-width handling

Byte, halfword, and word load selections implement sign extension or zero extension into the 64-bit result. The RTL also includes selections named after 32-bit word operations. Their current expressions should be checked against exact RV64 sign-extension requirements before treating them as ISA compliant.

### Status signals

The zero signal checks whether `aluResult_o` is zero; the negative signal reflects its top bit. The carry and overflow outputs are driven from addition-related logic rather than being separately recalculated for every selected operation. In particular, the overflow expression is not a complete signed-overflow detector and should not be used as proof of correct overflow behavior.

## Testbench and verification

`ALU_MOD_TB.sv` instantiates `alumod`, drives operand and selector inputs, waits for combinational settling, calculates expected results, and checks outputs. The testbench includes a `run_test` task and operation-specific expected-result expressions.

The available testbench exercises selector values **0 through 43** in its operation loop. Selector **44** exists in the design but is not covered by that loop.

### Suggested test scenarios

- Addition/subtraction with zero, positive, and negative operands.
- Bitwise logic using alternating-bit patterns.
- Shifts by 0, 1, and the maximum supported shift amount.
- Signed versus unsigned comparisons with high-bit-set operands.
- Sign extension of byte, halfword, and word values.
- Equality and inequality for branch-condition outputs.
- Result-zero and result-negative cases.
- Boundary conditions for carry and signed overflow.

These are recommended verification targets, **not a claim that every case has passed**.

## How to simulate in Xilinx Vivado

1. Open **Vivado** and select **Create Project**.
2. Choose an **RTL Project** and select a suitable target device or board for your local environment.
3. Add `ALU_MOD.sv` under **Design Sources**.
4. Add `ALU_MOD_TB.sv` under **Simulation Sources**.
5. Set **`tb_alumod`** as the simulation top module.
6. Select **Run Simulation → Run Behavioral Simulation**.
7. Inspect the simulator transcript for checks/errors and open the waveform view.
8. Compare `data01_i`, `data02_i`, `aluSel_i`, `aluResult_o`, and the status outputs.

The packaged source has **not been independently re-simulated or proven to pass all assertions**. Fix any mismatches found during local simulation before reporting successful verification.

## Example functional expectations

| Inputs / selection | Expected idea |
| --- | --- |
| `data01_i = 5`, `data02_i = 3`, `aluSel_i = 0` | ADD result = 8 |
| `data01_i = 9`, `data02_i = 4`, `aluSel_i = 1` | SUB result = 5 |
| `data01_i = 0xF0`, `data02_i = 0x0F`, `aluSel_i = 2` | AND result = 0 |
| Equal operands, `aluSel_i = 31` | BEQ comparison result = 1 |

These examples describe basic intended functionality, not recorded simulation evidence.

## Current limitations

- This is an **ALU module**, not an integrated processor, register file, instruction decoder, or memory subsystem.
- Operation names do not guarantee full compliance with RISC-V instruction semantics.
- Some immediate and 32-bit word-operation expressions need closer review for sign extension and width rules.
- The carry and overflow signals need operation-aware definitions and additional testing.
- Parameterizing `reg_width` does not automatically make every hard-coded extension portable.
- The existing testbench does not cover selector 44 in its main loop.
- No independently verified simulation pass report, synthesis timing result, FPGA deployment, or resource-utilization result is included here.

## Future improvements

1. Align each implemented operation with the RISC-V ISA specification.
2. Correct signed-overflow and carry/borrow status handling.
3. Add directed boundary tests and randomized test vectors.
4. Expand coverage to every selector, including default and invalid codes.
5. Add assertions and functional coverage reports.
6. Refactor width-dependent expressions for robust parameterization.
7. Include verified simulation waveforms and synthesis reports when available.

## Skills demonstrated by the codebase

- Combinational RTL design with SystemVerilog.
- Arithmetic and Boolean datapath implementation.
- Signed/unsigned operations and bit manipulation.
- Testbench structure and expected-result checking.
- Familiarity with a Vivado-based RTL simulation workflow.

## Authorship, credits, and licensing

**Portfolio name:** Ritul Mahajan.

Please document the actual code author(s), contributors, and your individual contribution accurately. If any files were copied or adapted from another GitHub repository, preserve the original copyright notices and applicable license, and credit the original source. A repository-wide license must not imply ownership of third-party code.
