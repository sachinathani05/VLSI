`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.01.2026 08:52:45
// Design Name: 
// Module Name: tick_1s
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tick_1s #(
    parameter CLK_FREQ = 50_000_000
)(
    input wire clk,
    input wire rst,
    output reg  tick
);

integer count;

always @(posedge clk) begin
    if(rst) begin
        count <= 0;
        tick  <= 0;
    end else if (count == CLK_FREQ-1) begin
        count <= 0;
        tick  <= 1;
    end else begin
        count <= count+1;
        tick  <= 0;
    end
end

endmodule
