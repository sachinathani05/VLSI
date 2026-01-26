module tb_d_ff;

reg clk,rst,d;
wire q;

d_ff DUT (
	.clk(clk),
	.rst(rst),
	.d(d),
	.q(q),
	.qn(qn)
);

always #5 clk=~clk;

initial begin
	clk=0;rst=1;d=0;
#10 rst=0;
#10 d=1;
#10 d=0;
#20 $finish;
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_d_ff);
end

endmodule