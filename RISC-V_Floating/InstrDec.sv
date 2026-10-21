module InstrDec (
    input logic [31:0] instr,
    output logic [4:0] rs1, rs2, rd,
    output logic [2:0] fpOpType,
    output logic writeReg,
    output logic isFP
);
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd  = instr[11:7];

    // Identify FP operation (assume opcode[6:0] = 0x53)
    assign isFP = (instr[6:0] == 7'b1010011);
    assign writeReg = isFP;

    // Decode funct7/funct3 for FP ALU ops
    logic [6:0] funct7;
    assign funct7 = instr[31:25];

    always_comb begin
        case ({funct7, instr[14:12]})
            {7'b0000000, 3'b000}: fpOpType = 3'b000; // FADD.S
            {7'b0000100, 3'b000}: fpOpType = 3'b001; // FSUB.S
            {7'b0001000, 3'b000}: fpOpType = 3'b010; // FMUL.S
            {7'b0001100, 3'b000}: fpOpType = 3'b011; // FDIV.S
            default:              fpOpType = 3'b000;
        endcase
    end
endmodule
