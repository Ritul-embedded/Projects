`timescale 1ns/1ps

module alumod #(
    parameter reg_width = 64,              // Register width (64 bits)
    parameter aluselrv_width = 6           // ALU selection width (6 bits to support more operations)
) (
    input  logic [reg_width-1:0]      data01_i,
    input  logic [reg_width-1:0]      data02_i,
    input  logic [aluselrv_width-1:0] aluSel_i,
    output logic                      aluZero_o,
    output logic                      aluNega_o,
    output logic                      aluCarr_o,
    output logic                      aluOver_o,
    output logic [reg_width-1:0]      aluResult_o
);

  // Internal signals
  logic [reg_width-1:0] sum_s, sub_s, slt_result_s, sltu_result_s, xor_result_s;
  logic [reg_width-1:0] shl_s, shr_s, sar_s, lui_result_s, auipc_result_s;
  logic [reg_width-1:0] load_byte_s, load_half_s, load_word_s, load_dword_s;
  logic [reg_width-1:0] load_byte_u_s, load_half_u_s, load_word_u_s;
  logic carry_s, overf_s;
  logic signed [reg_width-1:0] data01_s, data02_s;

  // Data conversion (signed versions)
  assign data01_s   = data01_i;
  assign data02_s   = data02_i;

  // Arithmetic and Logical Operations
  assign {carry_s, sum_s} = data01_i + data02_i; // Addition with carry
  assign sub_s            = data01_i - data02_i; // Subtraction
  assign shl_s            = data01_i << data02_i[5:0]; // SLL
  assign shr_s            = data01_i >> data02_i[5:0]; // SRL
  assign sar_s            = data01_s >>> data02_i[5:0]; // SRA

  // Load Operations
  assign load_byte_s  = {{56{data01_i[7]}}, data01_i[7:0]};   // LB
  assign load_half_s  = {{48{data01_i[15]}}, data01_i[15:0]}; // LH
  assign load_word_s  = {{32{data01_i[31]}}, data01_i[31:0]}; // LW
  assign load_dword_s = data01_i;                            // LD
  assign load_byte_u_s  = {{56{1'b0}}, data01_i[7:0]};       // LBU
  assign load_half_u_s  = {{48{1'b0}}, data01_i[15:0]};      // LHU
  assign load_word_u_s  = {{32{1'b0}}, data01_i[31:0]};      // LWU

  // Load Upper Immediate (LUI) and Add Upper Immediate to PC (AUIPC)
  assign lui_result_s   = {data02_i[31:0], 32'b0};           // LUI
  assign auipc_result_s = data01_i + {data02_i[31:0], 12'b0}; // AUIPC

  always_comb begin
    case (aluSel_i)
      // 32-bit Instructions
      0  : aluResult_o = sum_s;                    // ADD
      1  : aluResult_o = sub_s;                    // SUB
      2  : aluResult_o = data01_i & data02_i;      // AND
      3  : aluResult_o = data01_i | data02_i;      // OR
      4  : aluResult_o = data01_i ^ data02_i;      // XOR
      5  : aluResult_o = shl_s;                    // SLL
      6  : aluResult_o = shr_s;                    // SRL
      7  : aluResult_o = sar_s;                    // SRA
      8  : aluResult_o = (data01_s < data02_s);    // SLT
      9  : aluResult_o = (data01_i < data02_i);    // SLTU
      10 : aluResult_o = data01_i + data02_i[31:0]; // ADDI
      11 : aluResult_o = data01_i << data02_i[5:0]; // SLLI
      12 : aluResult_o = data01_i >> data02_i[5:0]; // SRLI
      13 : aluResult_o = data01_s >>> data02_i[5:0]; // SRAI
      14 : aluResult_o = data01_i ^ data02_i[31:0]; // XORI
      15 : aluResult_o = data01_i | data02_i[31:0]; // ORI
      16 : aluResult_o = data01_i & data02_i[31:0]; // ANDI
      17 : aluResult_o = auipc_result_s;           // AUIPC
      18 : aluResult_o = load_byte_s;              // LB
      19 : aluResult_o = load_half_s;              // LH
      20 : aluResult_o = load_word_s;              // LW
      21 : aluResult_o = load_byte_u_s;            // LBU
      22 : aluResult_o = load_half_u_s;            // LHU
      23 : aluResult_o = load_word_u_s;            // LWU
      24 : aluResult_o = load_dword_s;             // LD

      // 64-bit Instructions
      25 : aluResult_o = data01_i + data02_i[31:0]; // ADDIW
      26 : aluResult_o = data01_i << data02_i[5:0]; // SLLIW
      27 : aluResult_o = data01_i >> data02_i[5:0]; // SRLIW
      28 : aluResult_o = data01_s >>> data02_i[5:0]; // SRAIW
      29 : aluResult_o = data01_i[31:0] + data02_i[31:0]; // ADDW
      30 : aluResult_o = data01_i[31:0] - data02_i[31:0]; // SUBW

      // Branches and Jumps
      31 : aluResult_o = (data01_i == data02_i); // BEQ
      32 : aluResult_o = (data01_i != data02_i); // BNE
      33 : aluResult_o = (data01_s < data02_s);  // BLT
      34 : aluResult_o = (data01_s >= data02_s); // BGE
      35 : aluResult_o = (data01_i < data02_i);  // BLTU
      36 : aluResult_o = (data01_i >= data02_i); // BGEU

      // Jump and Link
      37 : aluResult_o = data01_i + {{data02_i[30:0], 1'b0}}; // Jump target

      // Functions
      38 : aluResult_o = (data01_s < $signed(data02_i[31:0]));      // SLTI
      39 : aluResult_o = (data01_i < data02_i[31:0]);              // SLTIU
      40 : aluResult_o = data01_i;                                // SB (store byte)
      41 : aluResult_o = data01_i;                                // SH (store halfword)
      42 : aluResult_o = data01_i;                                // SW (store word)
      43 : aluResult_o = data01_i + data02_i[31:0];               // JALR
      44 : aluResult_o = data01_i;                                // SD (store doubleword)

      default: aluResult_o = 0;
    endcase
  end

  assign aluZero_o = (aluResult_o == 0);
  assign aluNega_o = aluResult_o[reg_width-1];
  assign aluCarr_o = carry_s;
  assign aluOver_o = (data01_i[reg_width-1] != sum_s[reg_width-1]);

endmodule
