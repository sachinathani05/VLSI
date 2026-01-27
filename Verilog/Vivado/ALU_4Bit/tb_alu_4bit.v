`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.01.2026 09:35:34
// Design Name: 
// Module Name: tb_alu_4bit
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


module tb_alu_4bit;
reg  [3:0] a, b;
reg  [2:0] sel;
wire [3:0] result;
wire carry;
wire zero;

alu_4bit dut (
    .a(a),
    .b(b),
    .sel(sel),
    .result(result),
    .carry(carry),
    .zero(zero)
);

initial begin
    a = 4'd0; b = 4'd0; sel = 3'b000;

    #10 a = 4'd5; b = 4'd3; sel = 3'b000; // ADD
    #10 sel = 3'b001;                    // SUB
    #10 sel = 3'b010;                    // AND
    #10 sel = 3'b011;                    // OR
    #10 sel = 3'b100;                    // XOR

    #10 a = 4'd2; b = 4'd2; sel = 3'b001; // zero test

    #20 $stop;
end

endmodule
