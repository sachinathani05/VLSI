module mux4x1 (
	input wire d0, d1, d2, d3, 
	input wire [1:0] sel,
	output reg y
);

always @(*) begin
	case (sel)
		2'b00: y=d0;
		2'b01: y=d1;
		2'b10: y=d2;
		2'b11: y=d3;
		default: y=1'b0;
		
	endcase
end

endmodule