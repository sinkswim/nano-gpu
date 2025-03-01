module geometry_unit (
    input logic clk,
    input logic reset,
    input logic [8:0] x1, y1,       // Start point (9 bits)
    input logic [8:0] x2, y2,       // End point (9 bits)
    input logic [7:0] color,        // Line color
    input logic start,              // Start drawing
    output logic [8:0] pixel_x,     // Pixel x coordinate
    output logic [8:0] pixel_y,     // Pixel y coordinate
    output logic [7:0] pixel_color, // Pixel color
    output logic pixel_valid        // Pixel ready
);
    // Internal signals
    logic [8:0] x, y;               // Current position
    logic [9:0] dx, dy;             // Deltas (10 bits to handle abs)
    logic [10:0] error;             // Error term (11 bits for signed calc)
    logic signed [9:0] sx, sy;      // Step direction (+1 or -1)
    logic steep;                    // Is |dy| > |dx|?
    logic done;                     // Line finished

    // State machine states
    typedef enum logic [1:0] {
        IDLE,
        INIT,
        DRAW
    } state_t;
    state_t state, next_state;

    // State machine
    always_ff @(posedge clk or posedge reset) begin
        if (reset) state <= IDLE;
        else state <= next_state;
    end

    // Next state and output logic
    always_comb begin
        next_state = state;
        pixel_valid = 0;
        done = 0;

        case (state)
            IDLE: begin
                if (start) next_state = INIT;
            end
            INIT: next_state = DRAW;
            DRAW: begin
                pixel_valid = 1;
                if ((x == x2) && (y == y2)) begin
                    done = 1;
                    next_state = IDLE;
                end
            end
        endcase
    end

    // Line drawing logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            x <= 0;
            y <= 0;
            dx <= 0;
            dy <= 0;
            error <= 0;
            sx <= 0;
            sy <= 0;
            steep <= 0;
            pixel_x <= 0;
            pixel_y <= 0;
            pixel_color <= 0;
        end else begin
            case (state)
                IDLE: begin
                    // Do nothing
                end
                INIT: begin
                    // Normalize direction and compute deltas
                    steep = (abs(y2 - y1) > abs(x2 - x1));
                    if (steep) begin
                        x = y1;
                        y = x1;
                        dx = abs(y2 - y1);
                        dy = abs(x2 - x1);
                        sx = (y1 < y2) ? 1 : -1;
                        sy = (x1 < x2) ? 1 : -1;
                    end else begin
                        x = x1;
                        y = y1;
                        dx = abs(x2 - x1);
                        dy = abs(y2 - y1);
                        sx = (x1 < x2) ? 1 : -1;
                        sy = (y1 < y2) ? 1 : -1;
                    end
                    error = (dx > dy) ? (dx >> 1) : -(dy >> 1); // Initial error
                    pixel_x = steep ? y : x;  // Swap if steep
                    pixel_y = steep ? x : y;
                    pixel_color = color;
                end
                DRAW: if (!done) begin
                    if (dx > dy) begin  // Shallow line
                        if (error >= 0) begin
                            y <= y + sy;
                            error <= error - dx;
                        end
                        error <= error + dy;
                        x <= x + sx;
                    end else begin      // Steep line
                        if (error >= 0) begin
                            x <= x + sy;
                            error <= error - dy;
                        end
                        error <= error + dx;
                        y <= y + sx;
                    end
                    pixel_x <= steep ? y : x;
                    pixel_y <= steep ? x : y;
                    pixel_color <= color;
                end
            endcase
        end
    end

    // Absolute value function
    function [9:0] abs(input logic [9:0] val);
        abs = val[9] ? -val : val;
    endfunction

endmodule