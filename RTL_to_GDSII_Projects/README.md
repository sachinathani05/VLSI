# RTL-to-GDSII Projects

Five connected projects spanning RTL design, UVM verification, and physical implementation — building toward a single full-stack flow from RTL through to manufacturing-ready GDSII.

---

## Project Status

| # | Project | Status | What It Covers |
|---|---------|--------|-----------------|
| 1 | [SPI Master — RTL & Directed Verification](P1_SPI_Master_RTL_Directed_Verification/) | ✅ Week 1 complete · 🟡 Week 2 (UVM) in progress | SystemVerilog FSM, directed testbench, 6/6 tests passing |
| 2 | [AXI4-Lite Verification IP](P2_AXI4_Lite_UVM_Verification/) | 🟡 In progress | UVM environment — driver, monitor, scoreboard, sequences |
| 3 | [UART RTL-to-GDSII (OpenLane/SKY130)](P3_RTL_to_GDSII_OpenLane_SKY130/) | ✅ Complete | Full physical design flow — synthesis through GDSII, 0 STA violations across 9 corners, clean DRC/LVS |
| 4 | [STA Timing Closure](P4_STA_Timing_Closure/) | 🟡 In progress | Custom SDC constraints, timing closure, ECO fixes |
| 5 | [RISC-V ALU — Full Stack Integration](P5_RISCV_ALU_Full_Stack/) | 🟡 In progress | RTL → synthesis → P&R → GDSII for a RISC-V ALU block |

---

## Why These Five Together

P1 and P2 build verification depth — moving from directed testing to full UVM with constrained-random stimulus and functional coverage. P3 proves the physical design flow end-to-end on a real design (UART), already taken to a clean, signed-off GDSII. P4 isolates timing closure as its own discipline. P5 brings RTL, verification, and physical implementation together on a single RISC-V block, closing the loop from design intent to silicon-ready layout.

---

## Contact

📧 sachinathani05@gmail.com  
🔗 [linkedin.com/in/sachin-athani](https://www.linkedin.com/in/sachin-athani)
