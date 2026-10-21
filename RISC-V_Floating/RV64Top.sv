module RV64Top (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instr,
    output logic [31:0] fpALUResult,

    // Preload ports for simulation/testing (safe for synthesis too)
    input  logic        test_write_en,
    input  logic [4:0]  test_write_addr,
    input  logic [31:0] test_write_data
);

    // Instruction Decode
    logic [4:0] rs1, rs2, rd;
    logic [2:0] fpOpType;
    logic writeReg, isFP;

    // Register File I/O
    logic [31:0] fpRegData1, fpRegData2;
    logic [31:0] wData;
    logic fpWriteEn;

    // Writeback condition
    assign wData = fpALUResult;
    assign fpWriteEn = (isFP && writeReg);

    // Instruction Decoder
    InstrDec decoder (
        .instr(instr),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .fpOpType(fpOpType),
        .writeReg(writeReg),
        .isFP(isFP)
    );

    // FP Register File (synth-safe)
    FPRegFile fprf (
        .clk(clk),
        .wEn(fpWriteEn),
        .rAddr1(rs1),
        .rAddr2(rs2),
        .wAddr(rd),
        .wData(wData),
        .rData1(fpRegData1),
        .rData2(fpRegData2),

        .test_write_en(test_write_en),
        .test_write_addr(test_write_addr),
        .test_write_data(test_write_data)
    );

    // FP ALU
    FPALU fpalu (
        .op1(fpRegData1),
        .op2(fpRegData2),
        .opType(fpOpType),
        .result(fpALUResult)
    );

endmodule
