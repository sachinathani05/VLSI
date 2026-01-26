module tb_syn_counter;

reg clk,rst;
wire [3:0]count;

syn_counter DUT (
	.clk(clk),
	.rst(rst),
	.count(count)
);

always #5 clk=~clk;

initial begin
	clk=0;rst=1;
#10 rst=0;
#200 $finish;

end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_syn_counter);
end

endmodule