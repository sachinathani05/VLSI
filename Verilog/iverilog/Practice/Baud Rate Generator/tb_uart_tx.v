module tb_uart_tx;

reg clk, rst;
reg tx_start;
reg [7:0] tx_data;
wire tx;
wire tx_busy;
wire baud_tick;

baud_gen #(
    .CLK_FREQ(1_000_000),  // lower for simulation
    .BAUD(9600)
) BG (
    .clk(clk),
    .rst(rst),
    .tick(baud_tick)
);

uart_tx DUT (
    .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .baud_tick(baud_tick),
    .tx(tx),
    .tx_busy(tx_busy)
);

// Clock generation
always #5 clk = ~clk;

initial begin
    $dumpfile("uart_tx.vcd");
    $dumpvars(0, tb_uart_tx);

    clk = 0;
    rst = 1;
    tx_start = 0;
    tx_data = 8'h00;

    #20 rst = 0;

    // Send character 'A' (0x41)
    #20 tx_data = 8'h41;
        tx_start = 1;
    #10 tx_start = 0;

    #200000 $finish;
end

endmodule
