module uart_rx #(
	parameter CLKS_PER_BIT = 5208
)(
	input	clk,
	input	rst_n,
	input	rx_in,
	output reg [7:0] rx_data,
	output reg rx_done
);

	localparam IDLE  = 2'b00;
	localparam START = 2'b01;
	localparam DATA  = 2'b10;
	localparam STOP  = 2'b11;

	reg [1:0]  state;
	reg [13:0] clk_count;
	reg [2:0]  bit_index;

	always @(posedge clk) begin
		if (!rst_n) begin
			state     <= IDLE;
			rx_done   <= 1'b0;
			clk_count <= 0;
			bit_index <= 0;
		end else begin
			rx_done <= 0;

		case (state)
 
			IDLE: begin
				clk_count <= 0;
				bit_index <= 0;
				if (rx_in == 1'b0) begin
					state <= START;
				end
			end

			START: begin	
				if (clk_count == (CLKS_PER_BIT/2) - 1) begin
					if (rx_in == 1'b0) begin
						clk_count <= 0;
						state     <= DATA;
					end else begin
						state     <= IDLE;
					end
				end else begin
					clk_count <= clk_count + 1;
				end
			end

			DATA: begin
				
				if (clk_count < CLKS_PER_BIT -1) begin
					clk_count <= clk_count + 1;
				end else begin
					clk_count <= 0;
					rx_data[bit_index] <= rx_in;
					if (bit_index < 7) begin
						bit_index <= bit_index + 1;
					end else begin
						bit_index <= 0;
						state     <= STOP;
					end
				end
			end

			STOP: begin
				if (clk_count < CLKS_PER_BIT - 1) begin
					clk_count <= clk_count + 1;
				end else begin
					rx_done	  <= 1'b1;
					clk_count <= 0;
					state     <= IDLE;
				end
			end
			
			default: state <= IDLE;

		endcase
	end
end
endmodule
