module frame_buffer (
    input logic clk,
    input logic we,
    input logic [16:0] addr,     // 17 bits for 320x240
    input logic [7:0] data_in,   // 8-bit color
    output logic [7:0] data_out  // For simulation
);
    logic [7:0] mem [0:76799];   // 320x240 array

    always_ff @(posedge clk) begin
        if (we) mem[addr] <= data_in;
        data_out <= mem[addr];
    end
endmodule