module comparator (
	input wire a,b,
	output reg	gt,eq,lt
);

always @(*) begin
	
	if (a>b) begin
	gt=1;eq=0;lt=0;
	end
	
	else if(a<b) begin
	gt=0;eq=0;lt=1;
	end
	
	else begin
	gt=0;lt=0;eq=1;
	end 
	
end

endmodule
