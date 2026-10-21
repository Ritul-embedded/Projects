module FPRegFile (
    input  logic        clk,
    input  logic        wEn,
    input  logic [4:0]  rAddr1, rAddr2, wAddr,
    input  logic [31:0] wData,
    output logic [31:0] rData1, rData2,

    // Test preload support
    input  logic        test_write_en,
    input  logic [4:0]  test_write_addr,
    input  logic [31:0] test_write_data
);
    logic [31:0] fregs[31:0];

    assign rData1 = fregs[rAddr1];
    assign rData2 = fregs[rAddr2];

    always_ff @(posedge clk) begin
        if (test_write_en)
            fregs[test_write_addr] <= test_write_data;
        else if (wEn)
            fregs[wAddr] <= wData;
    end
endmodule
