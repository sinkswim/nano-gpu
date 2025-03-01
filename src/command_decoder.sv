module command_decoder (
    input logic clk,
    input logic reset,
    input logic [47:0] cmd_data,    // 48-bit command input
    input logic cmd_valid,          // New command available
    output logic [8:0] x1, y1,      // Start point
    output logic [8:0] x2, y2,      // End point
    output logic [7:0] color,       // Line color
    output logic cmd_done,          // Signal to Geometry Unit
    output logic cmd_ready          // Ready for next command
);
    // State machine states
    typedef enum logic [1:0] {
        IDLE,
        PARSE,
        DISPATCH
    } state_t;
    state_t state, next_state;

    // Internal registers
    logic [8:0] x1_reg, y1_reg, x2_reg, y2_reg;
    logic [7:0] color_reg;
    logic [1:0] opcode;

    // State machine
    always_ff @(posedge clk or posedge reset) begin
        if (reset) state <= IDLE;
        else state <= next_state;
    end

    // Next state and output logic
    always_comb begin
        next_state = state;
        cmd_ready = 0;
        cmd_done = 0;
        x1 = x1_reg;
        y1 = y1_reg;
        x2 = x2_reg;
        y2 = y2_reg;
        color = color_reg;

        case (state)
            IDLE: begin
                cmd_ready = 1;
                if (cmd_valid) next_state = PARSE;
            end
            PARSE: begin
                next_state = DISPATCH;
            end
            DISPATCH: begin
                if (opcode == 2'b00) cmd_done = 1; // Draw line
                else cmd_done = 0;                 // Ignore invalid opcodes
                if (!cmd_valid) next_state = IDLE;
            end
        endcase
    end

    // Command parsing
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            x1_reg <= 0;
            y1_reg <= 0;
            x2_reg <= 0;
            y2_reg <= 0;
            color_reg <= 0;
            opcode <= 0;
        end else if (state == PARSE) begin
            opcode <= cmd_data[47:46];
            x1_reg <= cmd_data[45:37];
            y1_reg <= cmd_data[36:28];
            x2_reg <= cmd_data[27:19];
            y2_reg <= cmd_data[18:10];
            color_reg <= cmd_data[7:0];
        end
    end

endmodule