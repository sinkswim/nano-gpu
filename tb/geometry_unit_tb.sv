`timescale 1ns / 1ps

module geometry_unit_tb;
    logic clk, reset;
    logic [8:0] x1, y1, x2, y2;
    logic [7:0] color;
    logic start;
    logic [8:0] pixel_x, pixel_y;
    logic [7:0] pixel_color;
    logic pixel_valid;

    geometry_unit uut (
        .clk(clk), .reset(reset),
        .x1(x1), .y1(y1), .x2(x2), .y2(y2), .color(color), .start(start),
        .pixel_x(pixel_x), .pixel_y(pixel_y), .pixel_color(pixel_color),
        .pixel_valid(pixel_valid)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        reset = 1;
        x1 = 0; y1 = 0; x2 = 0; y2 = 0;
        color = 0;
        start = 0;
        #20;
        reset = 0;

        // Test 1: Line (0,0) to (5,5), color 0xFF
        @(posedge clk);
        x1 = 9'd0; y1 = 9'd0;
        x2 = 9'd5; y2 = 9'd5;
        color = 8'hFF;
        start = 1;
        @(posedge clk);
        start = 0;
        #200; // Wait for line to complete

        // Test 2: Line (10,10) to (15,12), color 0xAA
        @(posedge clk);
        x1 = 9'd10; y1 = 9'd10;
        x2 = 9'd15; y2 = 9'd12;
        color = 8'hAA;
        start = 1;
        @(posedge clk);
        start = 0;
        #200;

        $finish;
    end

        // Dump waveform for debugging
    initial begin
        $dumpfile("geometry_unit_tb.vcd");
        $dumpvars(0, geometry_unit_tb);
    end

endmodule