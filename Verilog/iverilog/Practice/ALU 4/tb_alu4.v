module tb_alu4;

reg [3:0] a;
reg [3:0] b;
reg [2:0] op;
wire zero;
wire [3:0] result;
wire carry;

alu4 DUT(
	.a(a),
	.b(b),
	.op(op),
	.result(result),
	.carry(carry),
	.zero(zero)
);

task check;
	input [3:0] exp_res;
	input exp_carry;
	
	begin
		if(result!==exp_res || carry!==exp_carry)
			$display("❌ FAIL | op=%b a=%d b=%d res=%d carry=%b",op, a, b, result, carry);
		else
			$display("✅ PASS | op=%b a=%d b=%d res=%d carry=%b",op, a, b, result, carry);
	end
endtask

initial begin
	$dumpfile("alu.vcd");
	$dumpvars(0,tb_alu4);
	
	// ADD
    a=4'd5; b=4'd3; op=3'b000; #5 check(4'd8, 0);
    a=4'd15; b=4'd1; op=3'b000; #5 check(4'd0, 1);

    // SUB
    a=4'd7; b=4'd2; op=3'b001; #5 check(4'd5, 0);

    // AND
    a=4'b1100; b=4'b1010; op=3'b010; #5 check(4'b1000, 0);

    // OR
    a=4'b1100; b=4'b1010; op=3'b011; #5 check(4'b1110, 0);

    // XOR
    a=4'b1100; b=4'b1010; op=3'b100; #5 check(4'b0110, 0);

    #10 $finish;
end

endmodule