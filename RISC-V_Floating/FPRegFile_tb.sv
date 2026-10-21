`timescale 1ns / 1ps

module FPRegFile_tb;

    logic clk, wEn;
    logic [4:0] rAddr1, rAddr2, wAddr;
    logic [31:0] wData, rData1, rData2;

    FPRegFile dut (
        .clk(clk),
        .wEn(wEn),
        .rAddr1(rAddr1),
        .rAddr2(rAddr2),
        .wAddr(wAddr),
        .wData(wData),
        .rData1(rData1),
        .rData2(rData2)
    );

    shortreal result;

    function automatic [31:0] f2b(input shortreal f);
        return $shortrealtobits(f);
    endfunction

    function automatic shortreal b2f(input [31:0] b);
        return $bitstoshortreal(b);
    endfunction

    function automatic shortreal fabs(input shortreal v);
        return (v < 0.0) ? -v : v;
    endfunction

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        wEn = 1;
        wAddr = 5'd5;
        wData = f2b(2.25);

        #12; // wait for rising clk edge
        wEn = 0;

        rAddr1 = 5'd5;
        rAddr2 = 5'd0;

        #2;
        result = b2f(rData1);
        $display("Read f5 = %f", result);
        assert(fabs(result - 2.25) < 0.0001)
            else $fatal("❌ FPRegFile read failed! Got %f", result);

        $display("✅ FPRegFile test passed!");
        #10 $finish;
    end
endmodule
