# =========================================================
# Clock Constraint ONLY (No board, no pins)
# =========================================================

# Assume 100 MHz clock → 10 ns period
create_clock -period 10.0 [get_ports clk]
