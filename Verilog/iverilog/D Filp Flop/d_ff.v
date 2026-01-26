module d_ff(
	input wire clk,rst,d,
	output reg q,qn
);

always @(posedge clk) begin
	if (rst)
		q<=1'b0;
	else
		q<=d;
		qn<=~d;
end

endmodule