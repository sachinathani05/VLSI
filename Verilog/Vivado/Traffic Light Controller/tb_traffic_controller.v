`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.01.2026 09:20:58
// Design Name: 
// Module Name: tb_traffic_controller
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


module tb_traffic_controller;

reg clk, rst;
wire tick;
wire ns_red, ns_yellow, ns_green; 
wire ew_red, ew_yellow, ew_green;

tick_1s #(
    .CLK_FREQ(10)
) TICK(
    .clk(clk),
    .rst(rst),
    .tick(tick)
);

traffic_controller DUT(
    .clk(clk),
    .rst(rst),
    .tick(tick),
    .ns_red(ns_red),
    .ns_yellow(ns_yellow),
    .ns_green(ns_green),
    .ew_red(ew_red),
    .ew_yellow(ew_yellow),
    .ew_green(ew_green)
);

always #5 clk=~clk;

initial begin
    clk = 0;
    rst = 1;
    
    #20 rst = 0;
    
    #500 $finish;
end

initial begin
    $monitor("Time=%0t | State=%b | NS[R=%b Y=%b G=%b] EW[R=%b Y=%b G=%b]",
             $time, DUT.state, ns_red, ns_yellow, ns_green,
             ew_red, ew_yellow, ew_green);
end

endmodule
