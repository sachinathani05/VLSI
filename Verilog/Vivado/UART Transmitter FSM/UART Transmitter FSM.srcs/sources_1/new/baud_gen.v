`timescale 1ns / 1ps

module baud_gen #(
    parameter CLK_FREQ = 1_000_000,
    parameter BAUD     = 9600
)(
    input  wire clk,
    input  wire rst,
    output reg  tick
);

localparam integer BAUD_DIV = CLK_FREQ / BAUD;
integer count;

always @(posedge clk) begin
    if (rst) begin
        count <= 0;
        tick  <= 0;
    end else if (count == BAUD_DIV-1) begin
        count <= 0;
        tick  <= 1;
    end else begin
        count <= count + 1;
        tick  <= 0;
    end
end

endmodule