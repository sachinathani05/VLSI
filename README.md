# VLSI Portfolio — Sachin Balappa Athani

MSc Microelectronics · Newcastle University (2025–2026)  
Design Verification · Analog/IC Layout · RTL Design

---

## Repository Structure

```
VLSI/
├── Cadence Virtuoso/
│   ├── 90nm (GPDK090)/
│   │   ├── CMOS Inverter/          ← Schematic · Layout · DRC/LVS · Parametric sweep · LTSpice cross-check
│   │   └── Ring Oscillator/        ← 1.45 GHz · W-L parametric sweep · freq/power CSV + plots
│   ├── 65nm (UMC)/
│   │   └── Standard Cell Design (EEE8127)/  ← Inverter · Tri-State Inv · DFF · Fanout · Wire delay · Energy-VDD
│   └── 45nm/
│       └── Project_01_Two_Stage_OTA_45nm/   ← AC · DC · Transient · Noise · CMRR · PSRR · Corner sweep
├── RTL_to_GDSII_Projects/
│   ├── P1_SPI_Master_RTL_Directed_Verification/  ← SPI Mode 0 FSM · 6/6 directed tests passing
│   ├── P2_AXI4_Lite_UVM_Verification/            ← In progress
│   ├── P3_RTL_to_GDSII_OpenLane_SKY130/          ← UART RTL-to-GDSII complete — 0 STA violations, GDS exported
│   ├── P4_STA_Timing_Closure/                    ← In progress
│   └── P5_RISCV_ALU_Full_Stack/                  ← In progress
├── Verilog/
│   ├── Vivado/
│   │   ├── ALU_4Bit/               ← 5-op ALU · carry + zero flags · synthesis report
│   │   ├── UART Transmitter FSM/   ← Baud gen + 4-state FSM · waveform
│   │   ├── Traffic Light Controller/   ← Moore FSM · FPGA constraints (.xdc)
│   │   └── 4-Bit Counter/          ← Synchronous counter · testbench
│   └── iverilog/
│       ├── Sequence Detector FSM (Moore)/  ← 101-pattern · two-process FSM · waveform
│       ├── 1 Bit Full Adder/
│       ├── 4-Bit Synchronous Counter/
│       ├── 8 Bit Register/
│       ├── ALU 4/
│       ├── Baud Rate Generator/
│       ├── Comparator/
│       ├── D Flip Flop/
│       └── Mux 4x1/
├── Fundamentals/
│   └── Sequential Logic/           ← D/SR/JK latches & flip-flops · counters · shift registers
└── RTOS/
    └── RTOS in M68K Assembly/      ← Round-robin · mutex · context switching · 6 system calls
```

---

## Highlights

### 45nm Two-Stage Miller-Compensated OTA (GPDK045) ✅
Complete schematic-to-signoff analog IC design in Cadence Virtuoso 45nm.

- **DC:** All signal-path devices in saturation. VOUT = 0.600V at mid-rail. M1/M2 matched within 0.3%.
- **AC:** DC gain 75.6 dB · GBW 57.5 MHz · Phase margin 60.9° (TT/27°C)
- **Transient:** SR rising 64.5 V/µs · SR falling 55 V/µs · Settling 18.6 ns rising
- **Noise:** Thermal floor 9.5 nV/√Hz · Flicker corner 1.4 MHz
- **CMRR:** 76.4 dB · **PSRR:** 164.4 dB
- **Corner sweep:** 9 corners (TT/SS/FF × −40/27/125°C) — FF corner identified as marginal, fix proposed
- **Layout signoff:** DRC clean (0 violations) · LVS matched (2 documented waivers) · PEX extracted
- **Post-layout debugging:** Root-caused an LVS-vs-RCX extraction discrepancy, a tail-node substrate short, and a structural M6 finger-wiring defect (series chain instead of parallel) — fully documented with proposed fix as a known limitation

### 65nm UMC Standard Cell Design (EEE8127 — Newcastle University)
Complete CMOS IC design flow in UMC 65nm using Cadence Virtuoso + Mentor Calibre.

- **Inverter:** Logical Effort sizing (2:1 → 1.6:1 corrected for dual-contact DRC rule). Post-PEX: tpHL +12.3%, energy/cycle +42.6%.
- **Fanout:** LE model validated FO0–FO4. Cin(schematic) = 0.703 fF, Cin(extracted) = 1.078 fF (+53%). LE overestimates delay by 60% at FO4.
- **Wire Delay:** Elmore RC validated. Crossover at ~55µm. Measured capacitance: 0.113 fF/µm.
- **Energy–VDD:** 48-stage chain sweep. MEP at 0.8V (+25.5% energy saving). EDP minimum at 1.2–1.4V.

### SPI Master RTL Design & Directed Verification (P1 of 5)
Parameterised SPI Master in SystemVerilog — 5-state Moore FSM, Mode 0.

- **Result:** 6/6 directed tests passing — 0 failures
- **Patterns tested:** Alternating bits (0xA5, 0x55), all-ones, all-zeros, LSB-only, MSB-only
- **Bugs documented:** 6 real RTL bugs found and fixed during development
- **Next:** Week 2 — UVM environment (seq_item → driver → monitor → scoreboard)

### UART — Full RTL-to-GDSII Flow (OpenLane/SKY130)
Complete physical design flow from RTL to manufacturing-ready GDSII using OpenLane 2, Yosys, OpenROAD, Magic, KLayout, and Netgen.

- **Synthesis:** 267 cells, 60 flip-flops, 3034.16 µm² — 0 CHECK problems
- **STA:** **0 setup/hold violations across all 9 PVT corners** — worst setup 10.55 ns, worst hold 0.144 ns
- **CTS:** Real measured clock skew ~1.6 ps
- **Routing:** 0 congestion overflow, 0 antenna violations, 0 DRC violations
- **Sign-off:** DRC clean (Magic + KLayout cross-check), LVS matched uniquely (Netgen)
- **Output:** 3 GDSII files generated, foundry-submission ready

### 90nm Ring Oscillator (GPDK090)
3-stage CMOS ring oscillator. Measured frequency: **1.45 GHz** (tp = 115 ps/stage). W-L parametric sweep with CSV + plots.

### 90nm CMOS Inverter (GPDK090)
Schematic, layout, DRC/LVS. DC transfer characteristic, transient propagation delay, VM parametric sweep. Cross-validated in LTSpice.

### RTOS in M68K Assembly (EEE8087 — Newcastle University)
Built from scratch. Round-robin scheduler, 16-register context switching, mutex, 6 system calls via `trap #0`.

---

## In Progress

| Project | Track | Tools |
|---------|-------|-------|
| SPI Master UVM Testbench (Week 2+) | Verification | SystemVerilog · UVM · QuestaSim |
| AXI4-Lite Verification IP | Verification | SystemVerilog · UVM |
| STA Timing Closure (custom RTL) | Physical Design | OpenSTA · SDC · TCL |
| RISC-V ALU — Full Stack Integration | Full Stack | RTL → Synthesis → P&R → GDSII |
| Low-Dropout Regulator (LDO) | Analog | Cadence Virtuoso 45nm |
| 6T SRAM, StrongARM, SC Integrator | Analog | Cadence Virtuoso 45nm |

---

## Contact

📧 sachinathani05@gmail.com  
🔗 [linkedin.com/in/sachin-athani](https://www.linkedin.com/in/sachin-athani)  
📍 Newcastle, UK · Graduate Route Visa
