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

    // Initialize memory to 0 (black background)
    initial begin
        for (int i = 0; i < 76800; i++) begin
            uut.mem[i] = 8'h00;
        end
    end

    // Test procedure: Draw diagonal line, circle, and star
    initial begin
        // Initialize signals
        we = 0;
        addr = 0;
        data_in = 0;

        // Wait for initialization
        #20;

        // 1. Draw diagonal line from (0,0) to (319,239)
        begin
            int x, y;
            for (x = 0; x < 320; x++) begin
                y = (x * 239) / 319;  // Scale y from 0 to 239
                @(posedge clk);
                we = 1;
                addr = y * 320 + x;
                data_in = 8'hFF;      // White
                @(posedge clk);
                we = 0;
            end
        end

        // 2. Draw circle in lower-left, center (80,160), radius 40
        begin
            int x, y, dx, dy, dist_sq;
            for (y = 120; y <= 200; y++) begin  // y: 160-40 to 160+40
                for (x = 40; x <= 120; x++) begin  // x: 80-40 to 80+40
                    dx = x - 80;
                    dy = y - 160;
                    dist_sq = dx*dx + dy*dy;
                    if (dist_sq <= 1600 && dist_sq >= 1444) begin  // r^2 = 40^2 = 1600, thickness ~2 pixels
                        @(posedge clk);
                        we = 1;
                        addr = y * 320 + x;
                        data_in = 8'hFF;  // White
                        @(posedge clk);
                        we = 0;
                    end
                end
            end
        end

        // 3. Draw 5-pointed star in upper-right, center (240,80), size ~60x60
        begin
            int x, y, dx, dy;
            real angle, r, star_factor;
            for (y = 50; y <= 110; y++) begin  // y: 80-30 to 80+30
                for (x = 210; x <= 270; x++) begin  // x: 240-30 to 240+30
                    dx = x - 240;
                    dy = y - 80;
                    angle = $atan2(dy, dx) * 180 / 3.14159;  // Angle in degrees
                    r = $sqrt(dx*dx + dy*dy);  // Distance from center
                    if (r <= 30) begin  // Within bounding circle
                        star_factor = $cos(5 * angle * 3.14159 / 180);  // 5-point modulation
                        if (star_factor > 0.3 && r > 10) begin  // Outer star arms
                            @(posedge clk);
                            we = 1;
                            addr = y * 320 + x;
                            data_in = 8'hFF;  // White
                            @(posedge clk);
                            we = 0;
                        end
                    end
                end
            end
        end

        // Dump memory and end simulation
        #20;
        $writememh("img/fb-dump/frame_buffer.hex", uut.mem);
        $finish;
    end

    // Dump waveform for debugging
    initial begin
        $dumpfile("frame_buffer_tb.vcd");
        $dumpvars(0, frame_buffer_tb);
    end

endmodule