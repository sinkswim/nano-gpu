module gpu_top (
    input logic clk,
    input logic reset,
    input logic [47:0] cmd_data,
    input logic cmd_valid,
    output logic cmd_ready
);
    logic [8:0] x1, x2, y1, y2;
    logic [7:0] color;
    logic cmd_done;
    logic [8:0] pixel_x, pixel_y;
    logic [7:0] pixel_color;
    logic pixel_valid;
    logic [16:0] fb_addr;
    logic [7:0] fb_data;
    logic fb_we;

    command_decoder cmd_dec (
        .clk(clk), .reset(reset),
        .cmd_data(cmd_data), .cmd_valid(cmd_valid), .cmd_ready(cmd_ready),
        .x1(x1), .y1(y1), .x2(x2), .y2(y2), .color(color),
        .cmd_done(cmd_done)
    );

    geometry_unit geo_unit (
        .clk(clk), .reset(reset),
        .x1(x1), .y1(y1), .x2(x2), .y2(y2), .color(color),
        .start(cmd_done),
        .pixel_x(pixel_x), .pixel_y(pixel_y), .pixel_color(pixel_color),
        .pixel_valid(pixel_valid)
    );

    rasterizer rast (
        .clk(clk), .reset(reset),
        .pixel_x(pixel_x), .pixel_y(pixel_y), .pixel_color(pixel_color),
        .pixel_valid(pixel_valid),
        .fb_addr(fb_addr), .fb_data(fb_data), .fb_we(fb_we)
    );

    frame_buffer fb (
        .clk(clk), .we(fb_we), .addr(fb_addr),
        .data_in(fb_data), .data_out()
    );
endmodule