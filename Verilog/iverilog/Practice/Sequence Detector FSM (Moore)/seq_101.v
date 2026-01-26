module seq_101 (
	input wire clk,rst,in,
	output reg out
);

parameter [1:0] s0=2'b00,
				s1=2'b01,
				s2=2'b10,
				s3=2'b11;
				
reg [1:0] state, next_state;

always @(posedge clk) begin
	if(rst)
		state<=s0;
	else
		state<=next_state;
end

always @(*) begin
	case (state)
		s0: next_state=in?s1:s0;
		s1: next_state=in?s1:s2;
		s2: next_state=in?s3:s0;
		s3: next_state=in?s1:s0;
		default: next_state=s0;
	endcase
end

always @(*) begin
	out = (state == s3);
end

endmodule