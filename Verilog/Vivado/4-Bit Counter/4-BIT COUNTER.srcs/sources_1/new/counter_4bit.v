`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.01.2026 13:40:19
// Design Name: 
// Module Name: counter_4bit
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

module counter_4bit(
    input  wire clk,
    input  wire rst,
    input  wire enable,
    input  wire load,
    input  wire [3:0] load_value,
    output reg  [3:0] count,
    output wire terminal_count  // High when count = 15
);

always @(posedge clk or posedge rst) begin
    if (rst)
        count <= 4'b0000;
    else if (load)
        count <= load_value;
    else if (enable)
        count <= count + 1;
end

assign terminal_count = (count == 4'b1111);

endmodule
