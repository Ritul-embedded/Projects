`timescale 1ns / 1ps

module FPALU_tb;

    logic [31:0] op1, op2, result;
    logic [2:0]  opType;

    FPALU dut (
        .op1(op1),
        .op2(op2),
        .opType(opType),
        .result(result)
    );

    function automatic [31:0] f2b(input shortreal f);
        return $shortrealtobits(f);
    endfunction

    function automatic shortreal b2f(input [31:0] b);
        return $bitstoshortreal(b);
    endfunction

    function automatic shortreal fabs(input shortreal v);
        return (v < 0.0) ? -v : v;
    endfunction

    task run_fp_op(
        input string name,
        input shortreal a, b,
        input shortreal expected,
        input [2:0] optype
    );
        shortreal actual_f;
        op1 = f2b(a);
        op2 = f2b(b);
        opType = optype;
        #1;
        actual_f = b2f(result);
        $display("%s: %f op %f = %f (expected %f)", name, a, b, actual_f, expected);

        assert(fabs(actual_f - expected) < 0.0001)
            else $fatal("❌ %s failed! Got %f, expected %f", name, actual_f, expected);
    endtask

    initial begin
        run_fp_op("ADD", 3.5, 1.5, 5.0, 3'b000);
        run_fp_op("SUB", 3.5, 1.5, 2.0, 3'b001);
        run_fp_op("MUL", 3.5, 1.5, 5.25, 3'b010);
        run_fp_op("DIV", 3.0, 1.5, 2.0, 3'b011);

        $display("✅ FPALU test passed!");
        #10 $finish;
    end
endmodule
