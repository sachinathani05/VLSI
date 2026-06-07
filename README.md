# VLSI Portfolio — Sachin Balappa Athani

MSc Microelectronics · Newcastle University (2025–2026)  
Design Verification · Analog/IC Layout · RTL Design

---

## Repository Structure

```
VLSI/
├── Cadence Virtuoso/
│   ├── CMOS Inverter/          ← Schematic · Layout · DRC/LVS · Simulation · LTSpice cross-check
│   ├── Ring Oscillator/        ← 1.45 GHz oscillation · W-L parametric sweep · freq/power plots
│   └── UMC 65nm/               ← EEE8127 Newcastle · Inverter · TSInv · DFF · Fanout · Wire delay · Energy-VDD
├── Verilog/
│   ├── Vivado/
│   │   ├── ALU_4Bit/           ← 5-op ALU · carry + zero flags · synthesis report
│   │   ├── UART Transmitter FSM/   ← Baud gen + 4-state FSM · waveform
│   │   ├── Traffic Light Controller/   ← Moore FSM · FPGA constraints (.xdc)
│   │   └── 4-Bit Counter/      ← Synchronous counter · testbench
│   └── iverilog/
│       ├── Sequence Detector FSM (Moore)/  ← 101-pattern · two-process FSM
│       ├── 1 Bit Full Adder/
│       ├── 4-Bit Synchronous Counter/
│       ├── 8 Bit Register/
│       ├── ALU 4/
│       ├── Baud Rate Generator/
│       ├── Comparator/
│       ├── D Flip-Flop/
│       └── Mux 4x1/
├── Fundamentals/
│   └── Sequential Logic/       ← D/SR/JK latches & flip-flops · counters · shift registers
└── RTOS/
    └── RTOS in M68K Assembly/  ← Round-robin · mutex · context switching · 6 system calls
```

---

## Highlights

### UMC 65nm Standard Cell Design (EEE8127 — Newcastle University)
Complete CMOS IC design flow in UMC 65nm using Cadence Virtuoso + Mentor Calibre.

- **Inverter:** Logical Effort sizing (2:1 → 1.6:1 corrected for dual-contact DRC rule). Post-PEX: tpHL +12.3%, energy/cycle +42.6%.
- **Fanout:** LE model validated FO0–FO4. Cin(schematic) = 0.703 fF, Cin(extracted) = 1.078 fF (+53%). LE overestimates delay by up to 60% at FO4 (Cpar/Cin ≈ 4:1).
- **Wire Delay:** Elmore RC validated. 1µm vs 100µm M1 wire. Crossover at ~55µm. Measured capacitance: 0.113 fF/µm.
- **Energy–VDD:** 48-stage chain, 0.4V–2.0V sweep. MEP at 0.8V (+25.5% energy saving, 2× delay). EDP minimum at 1.2–1.4V.

### Ring Oscillator (GPDK090)
3-stage CMOS ring oscillator. Measured frequency: **1.45 GHz** (tp = 115 ps/stage). W-L parametric sweep with frequency and power data exported as CSV + plots.

### UART Transmitter FSM
Baud rate generator + 4-state FSM (IDLE → START → DATA → STOP). Fully synchronous, reset-able, simulation waveform verified.

### RTOS in M68K Assembly (EEE8087 — Newcastle University)
Built from scratch on EASy68K. Round-robin scheduler, full 16-register context switching, mutex, 6 system calls via `trap #0`. Two application programs (stopwatch + radiation monitor with shared counter).

---

## In Progress

Advanced projects being added through mid-2026:

- SPI Master UVM Testbench (SystemVerilog · UVM · QuestaSim)
- AXI4-Lite Verification IP (SystemVerilog · UVM)
- RISC-V ALU RTL-to-GDSII (OpenLane · SKY130 PDK)
- STA Timing Closure (OpenSTA · SDC · TCL)
- Two-Stage Miller OTA, LDO, 6T SRAM, StrongARM Latch, SC Integrator (Cadence Virtuoso 45nm)

---

## Contact

📧 sachinathani05@gmail.com  
🔗 [linkedin.com/in/sachin-athani](https://www.linkedin.com/in/sachin-athani)
