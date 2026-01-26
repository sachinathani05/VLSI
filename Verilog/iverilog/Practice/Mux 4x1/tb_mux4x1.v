module tb_mux4x1;

reg	d0,d1,d2,d3;
reg [1:0] sel;

wire y;

mux4x1 DUT (
	.d0(d0),
	.d1(d1),
	.d2(d2),
	.d3(d3),
	.sel(sel),
	.y(y)
);

initial begin

d0=0;
d1=1;
d2=0;
d3=1;

	sel=2'b00;
#10 sel=2'b01;
#10 sel=2'b10;
#10 sel=2'b11;

#10 $finish;

end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_mux4x1);
end

endmodule