module alu4 (
	input wire [3:0] a,
	input wire [3:0] b,
	input wire [2:0] op,
	output reg [3:0] result,
	output reg carry,
	output wire zero
);

reg [4:0] temp;

always @(*) begin 
	carry=1'b0;
	temp=5'b0;
	
	case(op)
		3'b000: begin
			temp=a+b;
			result=temp[3:0];
			carry=temp[4];
		end
	
		3'b001: begin
			temp=a-b;
			result=temp[3:0];
			carry=temp[4];
		end
		
		3'b010: result=a&b;
		3'b011: result=a|b;
		3'b100: result=a^b;
		
		default: result=4'b0000;
	endcase
end

assign zero=(result==4'b0000);

endmodule