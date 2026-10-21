module FPALU (
    input  logic [31:0] op1,
    input  logic [31:0] op2,
    input  logic [2:0]  opType,
    output logic [31:0] result
);

//`ifdef SYNTHESIS
   
// assign result = 32'd0;  // placeholder
//`else
   
    shortreal f1, f2, fres;

    always_comb begin
        f1 = $bitstoshortreal(op1);
        f2 = $bitstoshortreal(op2);

        case (opType)
            3'b000: fres = f1 + f2;
            3'b001: fres = f1 - f2;
            3'b010: fres = f1 * f2;
            3'b011: fres = f1 / f2;
            default: fres = 0.0;
        endcase

        result = $shortrealtobits(fres);
    end
//`endif

endmodule
