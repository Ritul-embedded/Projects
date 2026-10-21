`timescale 1ns/1ps
module rowhammer_protection_tb_advanced;

    localparam ADDR_WIDTH = 32;
    localparam ROW_WIDTH  = 16;
    localparam THRESHOLD  = 2;

    logic clk, rst;
    logic [ADDR_WIDTH-1:0] mem_addr;
    logic mem_valid;
    logic refresh_trigger;
    logic [ROW_WIDTH-1:0] refresh_row;
    logic scrub_valid;
    logic [ADDR_WIDTH-1:0] scrub_addr;
    logic [ROW_WIDTH-1:0] dbg_row;
    logic [15:0] dbg_counter;

    rowhammer_protection #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .ROW_WIDTH  (ROW_WIDTH),
        .THRESHOLD  (THRESHOLD),
        .SCRUB_GAP  (5)
    ) dut (
        .clk            (clk),
        .rst            (rst),
        .mem_addr       (mem_addr),
        .mem_valid      (mem_valid),
        .refresh_trigger(refresh_trigger),
        .refresh_row    (refresh_row),
        .scrub_valid    (scrub_valid),
        .scrub_addr     (scrub_addr),
        .dbg_row        (dbg_row),
        .dbg_counter    (dbg_counter)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("rowhammer.vcd");
        $dumpvars(0, rowhammer_protection_tb_advanced);

        clk = 0;
        rst = 1;
        mem_valid = 0;
        mem_addr  = 0;

        repeat (3) @(posedge clk);
        rst = 0;

        // Hammer Row 0x0010 twice
        hammer_row(16'h0010);

        // Access non-hammer rows
        access_row(16'h0020);
        access_row(16'h0021);

        // Hammer Row 0x0040 again
        hammer_row(16'h0040);

        // Hammer Row 0x0010 again
        hammer_row(16'h0010);

        // Random traffic
        random_traffic_with_hammer();

        repeat (20) @(posedge clk);
        $finish;
    end

    task access_row(input [ROW_WIDTH-1:0] row);
        begin
            mem_addr  <= {row, 16'hABCD}; // arbitrary column bits
            mem_valid <= 1;
            @(negedge clk);
            mem_valid <= 0;
            @(negedge clk);
        end
    endtask

    task hammer_row(input [ROW_WIDTH-1:0] row);
        begin
            $display("[%0t] -- Hammering Row 0x%0h", $time, row);
            access_row(row);
            access_row(row); // THRESHOLD = 2
        end
    endtask

    task random_traffic_with_hammer;
        int i;
        for (i = 0; i < 20; i++) begin
            if (i == 5 || i == 15) begin
                hammer_row(16'h0055 + i);
            end else begin
                access_row($urandom_range(0, 65535));
            end
        end
    endtask

    always_ff @(posedge clk) begin
        if (mem_valid)
            $display("[%0t] Accessing Row = 0x%0h  Counter = %0d", $time, dbg_row, dbg_counter);

        if (refresh_trigger)
            $display("[%0t] >>> REFRESH TRIGGERED: row = 0x%0h", $time, refresh_row);

        // Assertion: refresh should be for hammered_row + 1
        if (refresh_trigger) begin
            if (refresh_row != dbg_row + 1) begin
                $error("[%0t] Refresh row incorrect. Got 0x%0h, expected 0x%0h", $time, refresh_row, dbg_row + 1);
            end
        end
    end

endmodule
