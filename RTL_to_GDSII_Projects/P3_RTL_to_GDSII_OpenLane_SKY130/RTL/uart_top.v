module uart_top #(
    parameter CLKS_PER_BIT = 5208
)(
    input        clk,         
    input        rst_n,       

    // TX interface
    input        tx_start,    
    input  [7:0] tx_data,      
    output       tx_out,      
    output       tx_done,     

    // RX interface
    input        rx_in,       
    output [7:0] rx_data,     
    output       rx_done      
);

    // Instantiate UART Transmitter
    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) u_uart_tx (
        .clk      (clk),
        .rst_n    (rst_n),
        .tx_start (tx_start),
        .tx_data  (tx_data),
        .tx_out   (tx_out),
        .tx_done  (tx_done)
    );

    // Instantiate UART Receiver
    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) u_uart_rx (
        .clk      (clk),
        .rst_n    (rst_n),
        .rx_in    (rx_in),
        .rx_data  (rx_data),
        .rx_done  (rx_done)
    );

endmodule
