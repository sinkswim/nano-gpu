`timescale 1ns / 1ps

module frame_buffer_tb;
    // Testbench signals
    logic clk;
    logic we;
    logic [16:0] addr;
    logic [7:0] data_in;
    logic [7:0] data_out;

    // Instantiate the frame buffer
    frame_buffer uut (
        .clk(clk),
        .we(we),
        .addr(addr),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock generation (50 MHz, 20ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Test procedure
    initial begin
        // Initialize signals
        we = 0;
        addr = 0;
        data_in = 0;

        // Reset/wait
        #20;

        // Test 1: Write color 0xFF (white) to (0,0) -> addr = 0
        @(posedge clk);
        we = 1;
        addr = 0;           // (0,0)
        data_in = 8'hFF;
        @(posedge clk);
        we = 0;             // Disable write

        // Test 2: Write color 0xAA to (1,1) -> addr = 1*320 + 1 = 321
        @(posedge clk);
        we = 1;
        addr = 17'd321;     // (1,1)
        data_in = 8'hAA;
        @(posedge clk);
        we = 0;

        // Test 3: Write color 0x55 to (319,239) -> addr = 239*320 + 319 = 76799
        @(posedge clk);
        we = 1;
        addr = 17'd76799;   // (319,239)
        data_in = 8'h55;
        @(posedge clk);
        we = 0;

        // Readback verification
        #20;
        addr = 0;           // Check (0,0)
        @(posedge clk);
        $display("Addr 0 (0,0): Expected 0xFF, Got 0x%h", data_out);

        addr = 17'd321;     // Check (1,1)
        @(posedge clk);
        $display("Addr 321 (1,1): Expected 0xAA, Got 0x%h", data_out);

        addr = 17'd76799;   // Check (319,239)
        @(posedge clk);
        $display("Addr 76799 (319,239): Expected 0x55, Got 0x%h", data_out);

        // End simulation
        #20;
        $finish;
    end

    // Dump waveform for debugging
    initial begin
        $dumpfile("frame_buffer_tb.vcd");
        $dumpvars(0, frame_buffer_tb);
    end

endmodule