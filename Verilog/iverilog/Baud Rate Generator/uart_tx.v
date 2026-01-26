module uart_tx (
	input wire clk,
	input wire rst,
	input wire tx_start,
	input wire [7:0] tx_data,
	input wire baud_tick,
	output reg tx,
	output reg tx_busy
);

parameter [1:0] IDLE  = 2'b00,
                START = 2'b01,
                DATA  = 2'b10,
                STOP  = 2'b11;

reg [1:0] state;
reg [2:0] bit_index;
reg [7:0] data_reg;

always @(posedge clk) begin
    if (rst) begin
        state     <= IDLE;
        tx        <= 1'b1;
        tx_busy  <= 1'b0;
        bit_index <= 0;
    end else if (baud_tick) begin
        case (state)
            IDLE: begin
                tx <= 1'b1;
                tx_busy <= 1'b0;
                if (tx_start) begin
                    data_reg <= tx_data;
                    state <= START;
                    tx_busy <= 1'b1;
                end
            end

            START: begin
                tx <= 1'b0; // start bit
                state <= DATA;
                bit_index <= 0;
            end

            DATA: begin
                tx <= data_reg[bit_index];
                if (bit_index == 7)
                    state <= STOP;
                else
                    bit_index <= bit_index + 1;
            end

            STOP: begin
                tx <= 1'b1;
                state <= IDLE;
            end
        endcase
    end
end

endmodule