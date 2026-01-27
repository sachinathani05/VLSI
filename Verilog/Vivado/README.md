# 🔧 Vivado RTL Design & Simulation Guide

This repository contains **Verilog RTL designs** developed and verified using **Xilinx Vivado** as part of my **digital design and FPGA learning roadmap**.  
The projects demonstrate **combinational logic, sequential logic, and FSM-based systems**, validated through **behavioral simulation**.

---

## 🧰 What is Vivado?

**Xilinx Vivado** is an industry-standard **FPGA design and verification tool** used for:

- RTL design using **Verilog / VHDL**
- Functional and timing simulation (XSIM)
- Logic synthesis and optimization
- FPGA implementation (place & route)
- Bitstream generation for hardware programming

In this repository, Vivado is mainly used for:
- **RTL design**
- **Testbench-based simulation**
- **FSM verification**
- **Pre-silicon functional validation**

---

## 📁 Vivado Project File Structure

Vivado organizes files into logical groups:

### 🔹 Design Sources
Contains the actual **RTL design files**:
- `.v` → Verilog modules (Counter, ALU, FSM, UART, etc.)

Example:
- counter_4bit.v
- alu_4bit.v
- traffic_light_controller.v
- uart_tx_fsm.v

---

### 🔹 Simulation Sources
Contains **testbench files** used to verify RTL functionality:
- Files usually prefixed with `tb_`

Example:
- tb_counter_4bit.v
- tb_alu_4bit.v
- tb_uart_tx.v

Testbenches:
- Generate clock & reset
- Apply input stimulus
- Capture outputs using waveforms

---

### 🔹 Constraints (Optional – for FPGA Hardware)
Used only when targeting real FPGA boards:
- `.xdc` files define pin mapping, clocks, and I/O standards

Example:
constraints.xdc

---

## ▶️ Step-by-Step: Create and Run a Vivado Project

---

## 🟢 STEP 1: Create a New Vivado Project

### 1.1 Launch and Setup
1. Open **Vivado Design Suite**
2. Click **Create Project**
3. Click **Next**

---

### 1.2 Project Details
- **Project Name:** `traffic_light_controller`
- **Project Location:**  
  Example:  
C:/Vivado_Projects/traffic_light

- ✅ Check **Create project subdirectory**
- Click **Next**

---

### 1.3 Project Type
- Select **RTL Project**
- ✅ Check **Do not specify sources at this time**
- Click **Next**

---

### 1.4 Select FPGA Board / Part (Important for .xdc)

If you plan to **run on real hardware**, select a board or part.

#### Option A: Board Selection
- Go to **Boards** tab
- Choose a supported board (e.g., **Basys3**)

#### Option B: Part Selection (Common for Learning)
- Go to **Parts** tab
- Select an FPGA device

Example (Basys3 – Artix-7):
xc7a35tcpg236-1

- Click **Next**
- Click **Finish**

✔ The project is now created.

---

## 🟢 STEP 2: Add Verilog Design Files

1. In **Project Manager**, click **Add Sources**
2. Select **Add or Create Design Sources**
3. Click **Add Files**
4. Add your `.v` RTL files
5. Click **Finish**

These files appear under **Design Sources**.

---

## 🟢 STEP 3: Add Testbench Files

1. Click **Add Sources**
2. Select **Add or Create Simulation Sources**
3. Add `tb_*.v` files
4. Click **Finish**

These files appear under **Simulation Sources**.

---

## 🟢 STEP 4: Run Behavioral Simulation

1. Click **Run Simulation**
2. Select **Run Behavioral Simulation**

Vivado launches **XSIM waveform viewer**.

---

## 🟢 STEP 5: Analyze Waveforms

In the waveform window, verify:
- Clock behavior
- Reset operation
- Output transitions
- FSM state changes
- Protocol timing (UART)

You can:
- Zoom in/out
- Add markers
- Measure delays

---

## 🧪 Simulation Flow Summary
RTL Code (.v)
↓
Testbench (tb_*.v)
↓
Vivado XSIM
↓
Waveform Verification


---

## 🧠 Designs Covered in This Repository

- **4-Bit Counter** – sequential logic & clocking
- **4-Bit ALU** – combinational arithmetic and logic
- **Traffic Light Controller** – FSM-based control system
- **UART Transmitter FSM** – serial communication protocol

---

## 🛠 Tool & Language

- **Vivado Design Suite**
- **XSIM Simulator**
- **Verilog HDL (IEEE 1364)**

---

## 📌 Notes

- RTL is written in a **synthesizable style**
- Designs are **technology-independent**
- Simulation is performed before FPGA deployment
- Constraints (`.xdc`) are optional unless hardware is used

---

## 📂 Repository Organization

Each module folder contains:
- RTL source file
- Testbench
- Waveform screenshots (if applicable)
- Individual `README.md` explaining:
  - Design concept
  - Inputs/outputs
  - Simulation steps

Example:


/Traffic_Light_Controller
├── traffic_light_controller.v
├── tb_traffic_light_controller.v
└── README.md


---

## 🚀 Purpose of This Repository

This repository represents my **hands-on RTL design and verification journey**, aligned with **FPGA and ASIC industry workflows**, and demonstrates:

- Strong understanding of RTL concepts
- Proper simulation-driven development
- Tool proficiency with Vivado
- FSM and sequential logic expertise
