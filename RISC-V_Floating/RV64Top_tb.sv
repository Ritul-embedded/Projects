`timescale 1ns / 1ps

module RV64Top_tb;

    logic clk;
    logic reset;
    logic [31:0] instr;

    // DUT instance
    RV64Top dut (
        .clk(clk),
        .reset(reset),
        .instr(instr)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    function [31:0] float_to_bits(input shortreal f);
        return $shortrealtobits(f);
    endfunction

    function shortreal bits_to_float(input [31:0] bits);
        return $bitstoshortreal(bits);
    endfunction

    function [31:0] make_fp_instr(input [6:0] funct7, input [4:0] rs2, input [4:0] rs1, input [2:0] funct3, input [4:0] rd, input [6:0] opcode);
        return {funct7, rs2, rs1, funct3, rd, opcode};
    endfunction

    task preload_operands;
        begin
            force dut.fprf.test_write_en = 1;
            force dut.fprf.test_write_addr = 5'd2;
            force dut.fprf.test_write_data = float_to_bits(1.0);
            #10;
            force dut.fprf.test_write_addr = 5'd3;
            force dut.fprf.test_write_data = float_to_bits(2.0);
            #10;
            force dut.fprf.test_write_en = 0;
        end
    endtask

    task check_result(input string name, input shortreal expected_float);
        shortreal actual_f;
        actual_f = bits_to_float(dut.fprf.fregs[1]);
        $display("%s: f1 = %f, expected = %f", name, actual_f, expected_float);
        assert (actual_f < expected_float + 0.001 && actual_f > expected_float - 0.001)
        else $fatal("❌ %s FAILED: got %f, expected %f", name, actual_f, expected_float);
    endtask

    initial begin
        reset = 1;
        instr = 0;
        #10;
        reset = 0;
        preload_operands();

        instr = make_fp_instr(7'b0000000, 5'd3, 5'd2, 3'b000, 5'd1, 7'b1010011);
        repeat (3) @(posedge clk); #1;
        check_result("FADD.S", 3.0);

        instr = make_fp_instr(7'b0000100, 5'd3, 5'd2, 3'b000, 5'd1, 7'b1010011);
        repeat (3) @(posedge clk); #1;
        check_result("FSUB.S", -1.0);

        instr = make_fp_instr(7'b0001000, 5'd3, 5'd2, 3'b000, 5'd1, 7'b1010011);
        repeat (3) @(posedge clk); #1;
        check_result("FMUL.S", 2.0);

        instr = make_fp_instr(7'b0001100, 5'd3, 5'd2, 3'b000, 5'd1, 7'b1010011);
        repeat (3) @(posedge clk); #1;
        check_result("FDIV.S", 0.5);

        $display("✅ All FP tests passed!");
        $finish;
    end

endmodule
