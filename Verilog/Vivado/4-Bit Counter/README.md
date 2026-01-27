# 4-Bit Synchronous Counter (Vivado)

## 📘 Description
This project implements a **4-bit synchronous up-counter** using Verilog HDL.  
The counter increments on every rising edge of the clock and resets to zero when reset is asserted.

This is a foundational sequential circuit used in:
- Timers
- Frequency dividers
- Control logic
- Digital systems datapaths

---

## 🧠 Design Concept
- **Type:** Sequential Logic
- **Clocked Design:** Updates on `posedge clk`
- **Reset:** Synchronous reset
- **Bit-width:** 4 bits → counts from 0 to 15

The counter demonstrates:
- Register-based design
- Proper reset handling
- Clock-driven state updates

---

## 📥 Inputs & 📤 Outputs

| Signal | Width | Description |
|------|------|------------|
| clk | 1 | System clock |
| rst | 1 | Active-high reset |
| count | 4 | Counter output |

---

## 🧪 Vivado Simulation Steps

### 1️⃣ Create Project
- Open **Vivado**
- Create **RTL Project**
- Do **not** add sources initially

### 2️⃣ Add Design Source
Add:
- `counter_4bit.v`

### 3️⃣ Add Simulation Source
Add:
- `tb_counter_4bit.v`

### 4️⃣ Run Simulation
Run Simulation → Run Behavioral Simulation


### 5️⃣ Verify Waveform
- Counter increments every clock
- Reset forces output to `0000`

---

## 📊 What to Observe in Waveform
- `count` increments sequentially
- Reset overrides counting
- No glitches (fully synchronous)

---

## 🧩 Key Learnings
- Sequential logic basics
- Clock + reset behavior
- Register-based design

---

## 🛠 Tool Used
- **Vivado Simulator (XSIM)**
