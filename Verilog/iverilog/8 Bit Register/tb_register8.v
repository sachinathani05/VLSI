module tb_register8;

reg clk,rst;
reg [7:0]d;
wire [7:0]q;

register8 DUT (
	.clk(clk),
	.rst(rst),
	.d(d),
	.q(q)
);

always #5 clk=~clk;

initial begin
	clk=0;rst=1;d=8'h00;
#10 rst=0;
#10 d=8'hA5;
#10 d=8'h3C;
#20 $finish;
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_register8);
end

endmodule