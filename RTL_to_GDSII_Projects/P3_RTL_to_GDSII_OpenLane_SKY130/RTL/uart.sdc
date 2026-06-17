# uart.sdc
# Timing constraints for UART RTL-to-GDSII project
# Clock: 50MHz, Technology: SKY130 130nm

# ─── CLOCK DEFINITION ───────────────────────────────────────────────
# Creates a clock called "clk" on the clk port
# Period = 20ns (1/50MHz)
# Rise edge at 0ns, fall edge at 10ns (50% duty cycle)
create_clock -name clk -period 20 [get_ports clk]

# ─── CLOCK UNCERTAINTY ──────────────────────────────────────────────
# Accounts for clock jitter and skew in the physical implementation
# (jitter = small random variation in clock edge arrival time)
# 0.5ns is a reasonable value for SKY130 at 50MHz
set_clock_uncertainty 0.5 [get_clocks clk]

# ─── INPUT DELAYS ───────────────────────────────────────────────────
# Assumes upstream logic uses 4ns of the 20ns clock period
# before signals arrive at our input ports
# Leaves 16ns for internal logic (minus clock uncertainty)
set_input_delay -clock clk -max 4 [get_ports {tx_start tx_data[*] rx_in rst_n}]

# ─── OUTPUT DELAYS ──────────────────────────────────────────────────
# Reserves 4ns of the clock period for downstream logic
# after signals leave our output ports
set_output_delay -clock clk -max 4 [get_ports {tx_out tx_done rx_data[*] rx_done}]

# ─── FALSE PATHS ────────────────────────────────────────────────────
# Reset is asynchronous infrastructure — not a data path
# Tell the tool not to perform timing analysis on it
set_false_path -from [get_ports rst_n]

