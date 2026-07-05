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
│       ├── Project_01_Two_Stage_OTA_45nm/   ← ✅ AC · DC · Transient · Noise · CMRR · PSRR · Corner sweep · DRC/LVS/PEX
│       ├── Project_02_OTA_LDO_Error_Amplifier/ ← ✅ 79.1dB · 46.87MHz GBW · 77.5° PM · DRC/LVS clean
│       └── Project_03_LDO_Voltage_Regulator/   ← ✅ 1.2V/50mA · 9 PVT corners · DRC/LVS/PEX · post-layout verified
├── RTL_to_GDSII_Projects/
│   ├── P1_SPI_Master_RTL_Directed_Verification/  ← SPI Mode 0 FSM · 6/6 directed tests passing
│   ├── P2_AXI4_Lite_UVM_Verification/            ← In progress
│   ├── P3_RTL_to_GDSII_OpenLane_SKY130/          ← UART RTL-to-GDSII complete — 0 STA violations, GDS exported + 3 depth exercises
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

### Cadence Virtuoso — Analog IC Design

**90nm GPDK090**

| Project | Key Results |
|---------|-------------|
| [CMOS Inverter](Cadence%20Virtuoso/90nm%20(GPDK090)/CMOS%20Inverter/) | Schematic · Layout · DRC/LVS · DC/transient simulation · VM parametric sweep · LTSpice cross-validation |
| [Ring Oscillator](Cadence%20Virtuoso/90nm%20(GPDK090)/Ring%20Oscillator/) | **f = 1.45 GHz** (tp = 115 ps/stage) · W-L parametric sweep · freq/power CSV + plots |

**65nm UMC — Standard Cell Design (EEE8127, Newcastle University)**

| Experiment | Key Result |
|-----------|------------|
| Inverter — full DRC/LVS/PEX | Post-PEX: tpHL +12.3%, energy/cycle +42.6% vs schematic |
| Fanout analysis (FO0–FO4) | Cin extracted = 1.078 fF vs schematic 0.703 fF (+53%). LE overestimates delay by 60% at FO4 |
| Wire delay — Elmore RC | Schematic-to-measured crossover at ~55µm. Capacitance 0.113 fF/µm (matches PDK) |
| Energy–VDD sweep (48-stage chain) | MEP at 0.8V (+25.5% energy saving). EDP minimum at 1.2–1.4V |

**45nm GPDK045 — Analog IC Design Series**

| Project | Key Results | Status |
|---------|-------------|--------|
| [P01 — Two-Stage Miller OTA](Cadence%20Virtuoso/45nm/Project_01_Two_Stage_OTA_45nm/) | Gain 75.6 dB · GBW 57.5 MHz · PM 60.9° · CMRR 76.4 dB · PSRR 164.4 dB · 9-corner sweep · DRC/LVS/PEX | ✅ Complete |
| [P02 — OTA_LDO Error Amplifier](Cadence%20Virtuoso/45nm/Project_02_OTA_LDO_Error_Amplifier/) | Gain 79.1 dB · GBW 46.87 MHz · PM 77.5° · DRC/LVS clean · M6/M7 parallel strapping fix | ✅ Complete |
| [P03 — 1.2V LDO Voltage Regulator](Cadence%20Virtuoso/45nm/Project_03_LDO_Voltage_Regulator/) | PM 46.57°–74.99° (schematic) · Post-layout 43.1°–73.8° · 9 PVT corners · DRC/LVS · C-only PEX | ✅ Complete |

---

### RTL-to-GDSII Projects

**SPI Master — RTL Design & Directed Verification (P1 of 5)**

- SystemVerilog 5-state Moore FSM, Mode 0 · 6/6 directed tests passing · 6 RTL bugs found and fixed
- Next: Week 2 UVM environment (seq_item → driver → monitor → scoreboard)

**UART — Full RTL-to-GDSII Flow (OpenLane/SKY130) ✅**

- **Synthesis:** 267 cells · 60 flip-flops · 3034.16 µm² · 0 CHECK problems
- **STA:** 0 setup/hold violations across all 9 PVT corners · worst setup 10.55 ns · worst hold 0.144 ns
- **Routing:** 0 congestion overflow · 0 antenna violations · 0 DRC violations
- **Sign-off:** DRC clean (Magic + KLayout cross-check) · LVS matched uniquely (Netgen) · 3 GDSII files exported
- **Exercises:** [Timing stress-test & ECO ceiling](RTL_to_GDSII_Projects/P3_RTL_to_GDSII_OpenLane_SKY130/Exercise1_Timing/) · [Congestion boundary hunt](RTL_to_GDSII_Projects/P3_RTL_to_GDSII_OpenLane_SKY130/Exercise2_Congestion/) · [Manual OpenROAD Tcl driving](RTL_to_GDSII_Projects/P3_RTL_to_GDSII_OpenLane_SKY130/Exercise3_ManualPD/)

---

### RTOS in M68K Assembly (EEE8087 — Newcastle University)
Built from scratch on EASy68K. Round-robin scheduler · 16-register context switching · mutex · 6 system calls via `trap #0`.

---

## In Progress

| Project | Track | Tools |
|---------|-------|-------|
| SPI Master UVM Testbench (Week 2+) | Verification | SystemVerilog · UVM · QuestaSim |
| AXI4-Lite Verification IP | Verification | SystemVerilog · UVM |
| STA Timing Closure (custom RTL) | Physical Design | OpenSTA · SDC · TCL |
| RISC-V ALU — Full Stack Integration | Full Stack | RTL → Synthesis → P&R → GDSII |
| 6T SRAM, StrongARM, SC Integrator | Analog | Cadence Virtuoso 45nm |

---

## Contact

📧 sachinathani05@gmail.com  
🔗 [linkedin.com/in/sachin-athani](https://www.linkedin.com/in/sachin-athani)  
📍 Newcastle, UK · Graduate Route Visa
