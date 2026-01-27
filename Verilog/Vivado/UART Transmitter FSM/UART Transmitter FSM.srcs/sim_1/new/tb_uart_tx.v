`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.01.2026 21:16:14
// Design Name: 
// Module Name: tb_uart_tx
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

module tb_uart_tx;

reg clk, rst;
reg tx_start;
reg [7:0] tx_data;
wire tx;
wire tx_busy;
wire baud_tick;

// Instantiate baud generator
baud_gen #(
    .CLK_FREQ(1_000_000),
    .BAUD(9600)
) BG (
    .clk(clk),
    .rst(rst),
    .tick(baud_tick)
);

// Instantiate UART transmitter
uart_tx DUT (
    .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .baud_tick(baud_tick),
    .tx(tx),
    .tx_busy(tx_busy)
);

// Clock generation (100 KHz for simulation speed)
always #5 clk = ~clk;

initial begin
    // Initialize signals
    clk = 0;
    rst = 1;
    tx_start = 0;
    tx_data = 8'h00;

    // Release reset
    #20 rst = 0;

    // Send character 'A' (ASCII 0x41 = 01000001)
    #100 tx_data = 8'h41;
         tx_start = 1;
    #10  tx_start = 0;
    
    // Wait for transmission
    wait(!tx_busy);
    
    // Send character 'B' (0x42)
    #100 tx_data = 8'h42;
         tx_start = 1;
    #10  tx_start = 0;
    
    wait(!tx_busy);

    #5000 $finish;
end

endmodule