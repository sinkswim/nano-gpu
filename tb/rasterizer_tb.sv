`timescale 1ns / 1ps

module rasterizer_tb;
    // Testbench signals
    logic clk, reset;
    logic [8:0] pixel_x, pixel_y;
    logic [7:0] pixel_color;
    logic pixel_valid;
    logic [16:0] fb_addr;
    logic [7:0] fb_data;
    logic fb_we;
    logic [7:0] fb_data_out;

    // Read address multiplexer (1: read address from testbench; 0: read address from frame buffer)
    logic select_test;
    logic [16:0] fb_addr_tb;
    logic [16:0] fb_addr_sig;
    assign fb_addr_sig = select_test ? fb_addr_tb : fb_addr;

    // Instantiate rasterizer
    rasterizer uut (
        .clk(clk), .reset(reset),
        .pixel_x(pixel_x), .pixel_y(pixel_y),
        .pixel_color(pixel_color), .pixel_valid(pixel_valid),
        .fb_addr(fb_addr), .fb_data(fb_data), .fb_we(fb_we)
    );

    // Instantiate frame buffer
    frame_buffer fb (
        .clk(clk), .we(fb_we), .addr(fb_addr_sig),
        .data_in(fb_data), .data_out(fb_data_out)
    );

    // Clock generation (20ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Test procedure
    initial begin
        // Initialize
        select_test = 0;
        reset = 1;
        pixel_x = 0;
        pixel_y = 0;
        pixel_color = 0;
        pixel_valid = 0;
        #20;
        reset = 0;

        // Test 1: Write (0,0), color 0xFF
        @(posedge clk);
        pixel_x = 9'd0;
        pixel_y = 9'd0;
        pixel_color = 8'hFF;
        pixel_valid = 1;
        @(posedge clk);
        pixel_valid = 0;

        // Test 2: Write (1,1), color 0xAA
        @(posedge clk);
        pixel_x = 9'd1;
        pixel_y = 9'd1;
        pixel_color = 8'hAA;
        pixel_valid = 1;
        @(posedge clk);
        pixel_valid = 0;

        // Test 3: Write (319,239), color 0x55
        @(posedge clk);
        pixel_x = 9'd319;
        pixel_y = 9'd239;
        pixel_color = 8'h55;
        pixel_valid = 1;
        @(posedge clk);
        pixel_valid = 0;

        // Readback via frame buffer
        @(posedge clk);
        select_test = 1;
        repeat(3) @(posedge clk);
        fb_addr_tb = 17'd0;     // (0,0)
        @(posedge clk);
        $display("Addr 0 (0,0): Expected 0xFF, Got 0x%h", fb_data_out);

        fb_addr_tb = 17'd321;   // (1,1)
        @(posedge clk);
        $display("Addr 321 (1,1): Expected 0xAA, Got 0x%h", fb_data_out);

        fb_addr_tb = 17'd76799; // (319,239)
        @(posedge clk);
        $display("Addr 76799 (319,239): Expected 0x55, Got 0x%h", fb_data_out);

        #20;
        $finish;
    end

    // Dump waveform
    initial begin
        $dumpfile("rasterizer_tb.vcd");
        $dumpvars(0, rasterizer_tb);
    end

endmodule