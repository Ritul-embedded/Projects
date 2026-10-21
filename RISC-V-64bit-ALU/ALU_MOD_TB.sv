`timescale 1ns/1ps

module tb_alumod;

  // Parameters
  parameter reg_width = 64;
  parameter aluselrv_width = 6;

  // DUT Ports
  logic [reg_width-1:0]      data01_i, data02_i;
  logic [aluselrv_width-1:0] aluSel_i;
  logic                      aluZero_o, aluNega_o, aluCarr_o, aluOver_o;
  logic [reg_width-1:0]      aluResult_o;

  // DUT Instantiation
  alumod #(
    .reg_width(reg_width),
    .aluselrv_width(aluselrv_width)
  ) dut (
    .data01_i(data01_i),
    .data02_i(data02_i),
    .aluSel_i(aluSel_i),
    .aluZero_o(aluZero_o),
    .aluNega_o(aluNega_o),
    .aluCarr_o(aluCarr_o),
    .aluOver_o(aluOver_o),
    .aluResult_o(aluResult_o)
  );

  // Testbench variables
  logic [reg_width-1:0] expected_result;
  logic expected_zero, expected_negative, expected_carry, expected_overflow;

  // Task to perform ALU operation and check results
  task run_test(input [aluselrv_width-1:0] aluSel, 
                input [reg_width-1:0] data01, 
                input [reg_width-1:0] data02);
    begin
      aluSel_i = aluSel;
      data01_i = data01;
      data02_i = data02;

      // Wait for combinational logic to settle
      #1;

      // Compute expected results
      unique case (aluSel)
        // 32-bit Instructions
        0  : expected_result = data01 + data02;                    // ADD
        1  : expected_result = data01 - data02;                    // SUB
        2  : expected_result = data01 & data02;                    // AND
        3  : expected_result = data01 | data02;                    // OR
        4  : expected_result = data01 ^ data02;                    // XOR
        5  : expected_result = data01 << data02[5:0];              // SLL
        6  : expected_result = data01 >> data02[5:0];              // SRL
        7  : expected_result = $signed(data01) >>> data02[5:0];    // SRA
        8  : expected_result = ($signed(data01) < $signed(data02)); // SLT
        9  : expected_result = (data01 < data02);                  // SLTU
        10 : expected_result = data01 + data02[31:0];              // ADDI
        11 : expected_result = data01 << data02[5:0];              // SLLI
        12 : expected_result = data01 >> data02[5:0];              // SRLI
        13 : expected_result = $signed(data01) >>> data02[5:0];    // SRAI
        14 : expected_result = data01 ^ data02[31:0];              // XORI
        15 : expected_result = data01 | data02[31:0];              // ORI
        16 : expected_result = data01 & data02[31:0];              // ANDI
        17 : expected_result = data01 + {data02[31:0], 12'b0};     // AUIPC
        18 : expected_result = {{56{data01[7]}}, data01[7:0]};     // LB
        19 : expected_result = {{48{data01[15]}}, data01[15:0]};   // LH
        20 : expected_result = {{32{data01[31]}}, data01[31:0]};   // LW
        21 : expected_result = {{56{1'b0}}, data01[7:0]};          // LBU
        22 : expected_result = {{48{1'b0}}, data01[15:0]};         // LHU
        23 : expected_result = {{32{1'b0}}, data01[31:0]};         // LWU
        24 : expected_result = data01;                             // LD

        // 64-bit Instructions
        25 : expected_result = data01 + data02[31:0];              // ADDIW
        26 : expected_result = data01 << data02[5:0];              // SLLIW
        27 : expected_result = data01 >> data02[5:0];              // SRLIW
        28 : expected_result = $signed(data01) >>> data02[5:0];    // SRAIW
        29 : expected_result = data01[31:0] + data02[31:0];        // ADDW
        30 : expected_result = data01[31:0] - data02[31:0];        // SUBW

        // Branches and Jumps
        31 : expected_result = (data01 == data02);                 // BEQ
        32 : expected_result = (data01 != data02);                 // BNE
        33 : expected_result = ($signed(data01) < $signed(data02)); // BLT
        34 : expected_result = ($signed(data01) >= $signed(data02));// BGE
        35 : expected_result = (data01 < data02);                  // BLTU
        36 : expected_result = (data01 >= data02);                 // BGEU

        // Jump and Link
        37 : expected_result = data01 + {{data02[30:0], 1'b0}};    // Jump target

        // Functions
        38 : expected_result = ($signed(data01) < $signed(data02[31:0])); // SLTI
        39 : expected_result = (data01 < data02[31:0]);            // SLTIU
        40 : expected_result = data01;                             // SB
        41 : expected_result = data01;                             // SH
        42 : expected_result = data01;                             // SW
        43 : expected_result = data01 + data02[31:0];              // JALR
        44 : expected_result = data01;                             // SD

        default: expected_result = 0;
      endcase

      expected_zero     = (expected_result == 0);
      expected_negative = expected_result[reg_width-1];
      expected_carry    = (aluSel == 0) && (data01 + data02 > {reg_width{1'b1}});
      expected_overflow = (aluSel == 0) && 
                          ((data01[reg_width-1] == data02[reg_width-1]) && 
                          (data01[reg_width-1] != expected_result[reg_width-1]));

      // Assertions
      assert(aluResult_o == expected_result) else $error("Mismatch on ALU result for aluSel = %0d", aluSel);
      assert(aluZero_o == expected_zero) else $error("Mismatch on Zero flag for aluSel = %0d", aluSel);
      assert(aluNega_o == expected_negative) else $error("Mismatch on Negative flag for aluSel = %0d", aluSel);
      assert(aluCarr_o == expected_carry) else $error("Mismatch on Carry flag for aluSel = %0d", aluSel);
      assert(aluOver_o == expected_overflow) else $error("Mismatch on Overflow flag for aluSel = %0d", aluSel);
    end
  endtask

  // Test all ALU operations
  initial begin
    for (int i = 0; i < 44; i++) begin
      run_test(i, 64'h123456789ABCDEF0, 64'hFEDCBA9876543210);
    end
    $display("All tests passed!");
    $finish;
  end
endmodule
