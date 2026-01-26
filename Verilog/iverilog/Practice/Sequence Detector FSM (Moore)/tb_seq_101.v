module tb_seq_101;

reg clk,rst,in;
wire out;

seq_101 DUT (
	.clk(clk),
	.rst(rst),
	.in(in),
	.out(out)
);

always #5 clk=~clk;

initial begin
	clk=0;rst=1;in=0;
#10 rst=0;

#10 in=1;
#10 in=0;
#10 in=1;
#10 in=0;

$display("time=%0t in=%b out=%b", $time, in, out);


#20 $finish;

end

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_seq_101);
end

endmodule