`timescale 1ns / 1ps

module gpu_top_tb;
    logic clk, reset;
    logic [47:0] cmd_data;
    logic cmd_valid;
    logic cmd_ready;

    gpu_top uut (
        .clk(clk), .reset(reset),
        .cmd_data(cmd_data), .cmd_valid(cmd_valid),
        .cmd_ready(cmd_ready)
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

        // Draw line (0,0) to (5,5), color 0xFF
        @(posedge clk);
        cmd_data = {2'b00, 9'd0, 9'd0, 9'd5, 9'd5, 2'b00, 8'hFF};
        cmd_valid = 1;
        @(posedge clk);
        cmd_valid = 0;

        #500; // Wait for line to render
        $finish;
    end

    initial begin
        $dumpfile("gpu_top_tb.vcd");
        $dumpvars(0, gpu_top_tb);
    end

    always @(posedge clk) begin
        if (uut.fb.we)
            $display("Frame Buffer Write: Addr=%d, Data=0x%h", uut.fb.addr, uut.fb.data_in);
    end
endmodule