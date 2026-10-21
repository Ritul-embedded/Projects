`timescale 1ns / 1ps

module InstrDec_tb;

    logic [31:0] instr;
    logic zero;
    logic [63:0] pc, nextAddr;
    logic [4:0] rAddr01, rAddr02, wAddr01;
    logic [63:0] imm, newPC;
    logic mem2reg, memWr, memRd, aluSrc, writeReg, isFP;
    logic [1:0] aluOp;
    logic [2:0] fpOpType;

    InstrDec dut (
        .instr(instr), .zero(zero), .pc(pc), .nextAddr(nextAddr),
        .rAddr01(rAddr01), .rAddr02(rAddr02), .wAddr01(wAddr01),
        .imm(imm), .newPC(newPC),
        .mem2reg(mem2reg), .memWr(memWr), .memRd(memRd),
        .aluOp(aluOp), .aluSrc(aluSrc), .writeReg(writeReg),
        .isFP(isFP), .fpOpType(fpOpType)
    );

    task test_instr(input string name, input [6:0] funct7, input [2:0] funct3, input [2:0] expected_op);
        instr = {funct7, 5'd3, 5'd2, funct3, 5'd1, 7'b1010011};
        #1;
        $display("%s → fpOpType = %b", name, fpOpType);
        assert(fpOpType == expected_op && isFP)
            else $fatal("❌ %s failed: got %b", name, fpOpType);
    endtask

    initial begin
        zero = 0;
        pc = 0; nextAddr = 0;

        test_instr("FADD.S", 7'b0000000, 3'b000, 3'b000);
        test_instr("FSUB.S", 7'b0000100, 3'b000, 3'b001);
        test_instr("FMUL.S", 7'b0001000, 3'b000, 3'b010);
        test_instr("FDIV.S", 7'b0001100, 3'b000, 3'b011);

        $display("✅ InstrDec test passed!");
        #10 $finish;
    end

endmodule
