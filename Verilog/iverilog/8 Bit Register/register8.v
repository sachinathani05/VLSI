module register8 (
	input wire clk,rst,
	input wire [7:0]d,
	output reg [7:0]q
);

always @(posedge clk) begin
	if (rst)
		q<=8'h00;
	else
		q<=d;
end

endmodule