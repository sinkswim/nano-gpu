`timescale 1ns / 1ps

module command_decoder_tb;
    logic clk, reset;
    logic [47:0] cmd_data;
    logic cmd_valid;
    logic [8:0] x1, y1, x2, y2;
    logic [7:0] color;
    logic cmd_done, cmd_ready;

    command_decoder uut (
        .clk(clk), .reset(reset),
        .cmd_data(cmd_data), .cmd_valid(cmd_valid),
        .x1(x1), .y1(y1), .x2(x2), .y2(y2), .color(color),
        .cmd_done(cmd_done), .cmd_ready(cmd_ready)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        reset = 1;
        cmd_data = 0;
        cmd_valid = 0;
        #20;
        reset = 0;

        // Test 1: Draw line (0,0) to (5,5), color 0xFF
        @(posedge clk);
        cmd_data = {2'b00, 9'd0, 9'd0, 9'd5, 9'd5, 2'b00, 8'hFF};
        cmd_valid = 1;
        @(posedge clk);
        cmd_valid = 0;
        #40;

        // Test 2: Draw line (10,10) to (15,12), color 0xAA
        @(posedge clk);
        cmd_data = {2'b00, 9'd10, 9'd10, 9'd15, 9'd12, 2'b00, 8'hAA};
        cmd_valid = 1;
        @(posedge clk);
        cmd_valid = 0;
        #40;

        // Test 3: Invalid opcode (shouldn’t trigger cmd_done)
        @(posedge clk);
        cmd_data = {2'b11, 9'd20, 9'd20, 9'd25, 9'd25, 2'b00, 8'hBB};
        cmd_valid = 1;
        @(posedge clk);
        cmd_valid = 0;
        #40;

        $finish;
    end

    always @(posedge clk) begin
        if (cmd_done)
            $display("Command: (%d,%d) to (%d,%d), Color: 0x%h", x1, y1, x2, y2, color);
    end

    initial begin
        $dumpfile("command_decoder_tb.vcd");
        $dumpvars(0, command_decoder_tb);
    end
endmodule