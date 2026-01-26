# RTL Design & Verification using Verilog 

This repository contains **RTL designs, testbenches, and simulations** developed as part of **Phase 2 – RTL Design, Simulation, and Debugging** in my VLSI learning roadmap.

All modules are implemented in **Verilog HDL**, simulated using **Icarus Verilog (iverilog)**, and verified using **GTKWave**.

This phase focuses on building **strong digital design fundamentals** required for **FPGA and ASIC roles**.

---

## 🧰 Tools Used

- **Icarus Verilog (iverilog)** – Verilog compiler
- **vvp** – Simulation runtime engine
- **GTKWave** – Waveform viewer (`.vcd`)
- **Git/GitHub** – Version control & documentation

---

## 📂 Repository Structure

Each folder contains:
- RTL design file
- Testbench
- Simulation waveform
- Individual README explaining the design

```
├── 1 Bit Full Adder
├── 4-Bit Synchronous Counter
├── 8 Bit Register
├── ALU 4
├── Baud Rate Generator
├── Comparator
├── D Flip Flop
├── Mux 4x1
├── Sequence Detector FSM (Moore)

```
---

## ▶️ How to Run Any Design (Icarus Verilog)

### Step 1: Compile
```bash
iverilog -o sim_out tb_<module>.v <module>.v
```
Step 2: Run Simulation
```bash
vvp sim_out
```
Step 3: View Waveform
```bash
gtkwave dump.vcd
```
