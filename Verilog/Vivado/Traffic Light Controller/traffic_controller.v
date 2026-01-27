`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.01.2026 09:03:39
// Design Name: 
// Module Name: traffic_controller
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


module traffic_controller(
    input wire clk,
    input wire rst,
    input wire tick,
    output reg ns_red,
    output reg ns_yellow,
    output reg ns_green,
    output reg ew_red,
    output reg ew_yellow,
    output reg ew_green
);

localparam [1:0] NS_GREEN = 2'b00;
localparam [1:0] NS_YELLOW =2'b01;
localparam [1:0] EW_GREEN = 2'b10;
localparam [1:0] EW_YELLOW = 2'b11;

reg [1:0] state, next_state;

always @(posedge clk) begin
    if (rst)
        state <= NS_GREEN;
    else if (tick)
        state <= next_state;
end

always @(*) begin
    case (state)
        NS_GREEN:  next_state = NS_YELLOW;
        NS_YELLOW: next_state = EW_GREEN;
        EW_GREEN:  next_state = EW_YELLOW;
        EW_YELLOW: next_state = NS_GREEN;
        default:   next_state = NS_GREEN;
     endcase
end

always @(*) begin
    ns_red = 0; ns_yellow = 0; ns_green = 0;
    ew_red = 0; ew_yellow = 0; ew_green = 0;
    
    case (state)
        NS_GREEN: begin
            ns_green = 1;
            ew_red   = 1;
        end
        NS_YELLOW: begin
            ns_yellow = 1;
            ew_red    = 1;
        end
        EW_GREEN: begin
            ew_green = 1;
            ns_red   = 1;
        end
        EW_YELLOW: begin
            ew_yellow = 1;
            ns_red    = 1;
        end
    endcase
end

endmodule
