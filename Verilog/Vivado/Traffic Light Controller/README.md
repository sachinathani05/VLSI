# Traffic Light Controller (FSM + Constraints)

## 📘 Description
This project implements a **Traffic Light Controller** using a **Moore FSM**.
It controls North-South and East-West traffic lights with safe sequencing.

---

## 🧠 Design Concept
- **Type:** Sequential FSM
- **States:** NS_GREEN, NS_YELLOW, EW_GREEN, EW_YELLOW
- **Timing Control:** Tick generator
- **FPGA-ready with constraints**

---

## 📥 Inputs & 📤 Outputs

| Signal | Description |
|------|------------|
| clk | System clock |
| rst | Reset |
| ns_red/yellow/green | North-South lights |
| ew_red/yellow/green | East-West lights |

---

## 🧪 Vivado Simulation Steps

### 1️⃣ Add Design Sources
- `tick_1s.v`
- `traffic_controller.v`

### 2️⃣ Add Simulation Source
- `tb_traffic_controller.v`

### 3️⃣ Run Behavioral Simulation
Run Simulation → Run Behavioral Simulation

---

## 📊 Expected Behavior
- Only one green active at a time
- State changes only on tick
- Proper red/yellow sequencing

---

## 📌 FPGA Constraints (.xdc)
Includes:
- Clock constraint
- Reset mapping
- LED pin mapping
- I/O standards

---

## 🧩 Key Learnings
- FSM design
- Clock division
- FPGA constraints
- Real hardware readiness

---

## 🛠 Tools Used
- Vivado Simulator
- Vivado Synthesis
- XDC Constraints
