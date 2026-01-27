# UART Transmitter (FSM Based)

## 📘 Description
This project implements a **UART Transmitter** using a **Finite State Machine (FSM)**.
It serially transmits 8-bit data using:
- Start bit
- Data bits (LSB first)
- Stop bit

---

## 🧠 Design Concept
- **Type:** Sequential FSM
- **States:** IDLE → START → DATA → STOP
- **Timing Control:** Baud rate generator
- **Industry-relevant protocol**

---

## 📥 Inputs & 📤 Outputs

| Signal | Width | Description |
|------|------|------------|
| clk | 1 | System clock |
| rst | 1 | Reset |
| tx_start | 1 | Start transmission |
| tx_data | 8 | Data byte |
| tx | 1 | UART transmit line |
| tx_busy | 1 | Transmission status |

---

## 🧪 Vivado Simulation Steps

### 1️⃣ Add Design Sources
- `baud_gen.v`
- `uart_tx.v`

### 2️⃣ Add Simulation Source
- `tb_uart_tx.v`

### 3️⃣ Run Behavioral Simulation

Run Simulation → Run Behavioral Simulation

---

## 📊 What to Verify
- TX line idle HIGH
- Start bit LOW
- Data transmitted LSB first
- Stop bit HIGH
- tx_busy behavior

---

## 🧠 FSM State Flow
IDLE → START → DATA → STOP → IDLE


---

## 🧩 Key Learnings
- FSM design
- Serial communication
- Baud rate timing
- Multi-module integration

---

## 🛠 Tool Used
- **Vivado XSIM**
