module uart_tx #(
	parameter CLKS_PER_BIT = 5208
)(
	input clk,
	input rst_n,
	input tx_start,
	input [7:0] tx_data,
	output reg tx_out,
	output reg tx_done
);

	localparam IDEL  = 2'b00;
	localparam START = 2'b01;
	localparam DATA  = 2'b10;
	localparam STOP  = 2'b11;

	reg [1:0] state;
	reg [12:0] clk_count;

	reg [2:0] bit_index;
	reg [7:0] tx_data_latch;

	always @(posedge clk) begin
		if (!rst_n) begin
		
			state     <= IDEL;
			tx_out    <= 1'b1;
			tx_done   <= 1'b0;
			clk_count <= 0;
			bit_index <= 0;
		end else begin
			tx_done   <= 1'b0;

			case (state)
				
				IDEL: begin
					tx_out    <= 1'b1;
					clk_count <= 0;
					bit_index <= 0;
					if (tx_start) begin
						tx_data_latch <= tx_data;
						state	      <= START;
					end
				end
			
				START: begin
					tx_out <= 1'b0;
					if (clk_count < CLKS_PER_BIT -1) begin 
						clk_count <= clk_count + 1;
					end else begin
						clk_count <= 0;
						state     <= DATA;
					end
				end

				DATA: begin
					tx_out <= tx_data_latch[bit_index];
					if (clk_count <= CLKS_PER_BIT -1) begin
						clk_count <= clk_count + 1;
					end else begin
						clk_count <= 0;
						if (bit_index < 7) begin
							bit_index <= bit_index + 1;
						end else begin
							bit_index <= 0;
							state     <= STOP;
						end
					end
				end
		
				STOP: begin
					tx_out <= 1'b1;
					if (clk_count < CLKS_PER_BIT - 1) begin
						clk_count <= clk_count + 1;
					end else begin
						clk_count <= 0;
						tx_done   <= 1'b1;
						state     <= IDEL;
					end
				end
			
				default: state <= IDEL; 
			endcase
		end
	end
endmodule












