module syn_counter (
	input wire clk,rst,
	output reg [3:0]count
);

always @(posedge clk) begin
	if (rst) 
		count<= 4'b000;
	else
		count<=count+1'b1;
end

endmodule	