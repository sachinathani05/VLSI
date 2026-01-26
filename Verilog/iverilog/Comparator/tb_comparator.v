module tb_comparator;

wire gt,eq,lt;
reg a,b;

comparator DUT (
	.a(a),
	.b(b),
	.gt(gt),
	.eq(eq),
	.lt(lt)
);

initial begin
	a=1;b=0;
#10 a=1;b=1;
#10 a=0;b=1;
#10 $finish; 
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_comparator);
end

endmodule