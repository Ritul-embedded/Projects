`timescale 1ns/1ps

module rowhammer_protection #(
    parameter int ADDR_WIDTH  = 32,
    parameter int ROW_WIDTH   = 16,
    parameter int ROW_COUNT   = 2 ** ROW_WIDTH,   // = 65 536
    parameter int THRESHOLD   = 2,                // demo
    parameter int SCRUB_GAP   = 5                 // demo
)(
    input  logic                  clk,
    input  logic                  rst,

    input  logic [ADDR_WIDTH-1:0] mem_addr,
    input  logic                  mem_valid,

    output logic                  refresh_trigger,
    output logic [ROW_WIDTH-1:0]  refresh_row,

    output logic                  scrub_valid,
    output logic [ADDR_WIDTH-1:0] scrub_addr

    // *** OPTIONAL DEBUG PORTS - comment for synthesis ***
  , output logic [15:0]           dbg_counter   // live counter for the row we are touching
  , output logic [ROW_WIDTH-1:0]  dbg_row
);

    // ----------------------------------------------------------
    // 1  Row access counters
    // ----------------------------------------------------------
    logic [15:0] row_counters [ROW_COUNT];
    logic [ROW_WIDTH-1:0] current_row;
    assign current_row = mem_addr[ADDR_WIDTH-1 -: ROW_WIDTH];

    // debug pins
    assign dbg_counter = row_counters[current_row];
    assign dbg_row     = current_row;

    logic hammer_detected;
    logic refresh_armed;
    logic [ROW_WIDTH-1:0] hammered_row;

    integer i;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            hammer_detected <= 0;
            refresh_armed   <= 0;
            hammered_row    <= '0;
            for (i = 0; i < ROW_COUNT; i++) row_counters[i] <= '0;
        end
        else begin
            // (A) count accesses
            if (mem_valid) begin
                row_counters[current_row] <= row_counters[current_row] + 1;

                // fire hammer only once per threshold crossing
                if ( row_counters[current_row] + 1 == THRESHOLD   // == not >=
                     && !hammer_detected
                     && !refresh_armed ) begin
                    hammer_detected <= 1;
                    hammered_row    <= current_row;
                    $display("[%0t] HAMMER DETECT row 0x%0h",
                              $time, current_row);
                end
            end

            // (B) clear flag after refresh pulse is over
            if (refresh_armed && !refresh_trigger) begin
                hammer_detected <= 0;
            end
        end
    end


    // ----------------------------------------------------------
    // 2  One-cycle refresh pulse
    // ----------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            refresh_trigger <= 0;
            refresh_row     <= '0;
            refresh_armed   <= 0;
        end
        else begin
            if (hammer_detected && !refresh_armed) begin
                refresh_trigger <= 1;
                refresh_row     <= hammered_row + 1;
                refresh_armed   <= 1;
            end
            else begin
                refresh_trigger <= 0;
            end

            // ready for next hammer once detector is cleared
            if (!hammer_detected)
                refresh_armed <= 0;
        end
    end

    // ----------------------------------------------------------
    // 3  Background scrub
    // ----------------------------------------------------------
    logic [$clog2(SCRUB_GAP)-1:0] scrub_timer;
    logic [ADDR_WIDTH-1:0]        scrub_counter;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            scrub_timer   <= '0;
            scrub_counter <= '0;
            scrub_valid   <= 0;
        end
        else begin
            if (scrub_timer == SCRUB_GAP-1) begin
                scrub_timer   <= '0;
                scrub_counter <= scrub_counter + 64;
                scrub_addr    <= scrub_counter;
                scrub_valid   <= 1;
            end
            else begin
                scrub_timer <= scrub_timer + 1;
                scrub_valid <= 0;
            end
        end
    end

    // ----------------------------------------------------------
    // 4  Lightweight assertions (sim only)
    // ----------------------------------------------------------
`ifndef SYNTHESIS
    // refresh pulse = 1 cycle
    assert property (@(posedge clk) disable iff(rst)
                     refresh_trigger |-> !refresh_trigger[->1]);

    // scrub pulse every SCRUB_GAP cycles
    assert property (@(posedge clk) disable iff(rst)
                     scrub_valid |-> ##(SCRUB_GAP) scrub_valid);
`endif
endmodule
