module rasterizer (
    input logic clk,
    input logic reset,
    input logic [8:0] pixel_x,      // 9-bit x coordinate (0–319)
    input logic [8:0] pixel_y,      // 9-bit y coordinate (0–239)
    input logic [7:0] pixel_color,  // 8-bit color
    input logic pixel_valid,        // New pixel ready
    output logic [16:0] fb_addr,    // Frame buffer address
    output logic [7:0] fb_data,     // Frame buffer data
    output logic fb_we              // Write enable
);
    // Internal signals
    logic [16:0] addr_calc;         // Temp for address calculation

    // Address calculation: y * 320 + x
    always_comb begin
        addr_calc = (pixel_y * 9'd320) + pixel_x;  // 9-bit * 320 fits in 17 bits
    end

    // Synchronous write logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            fb_addr <= 0;
            fb_data <= 0;
            fb_we   <= 0;
        end else begin
            if (pixel_valid) begin
                fb_addr <= addr_calc;
                fb_data <= pixel_color;
                fb_we   <= 1;
            end else begin
                fb_we   <= 0;  // Only write when valid
            end
        end
    end

endmodule