# Baud Rate Generator

## 📘 Description
Generates a lower-frequency clock used in UART serial communication.

---

## 🧠 Design Concept
- **Type:** Sequential Logic
- Clock divider

---

## 📥 Inputs & 📤 Outputs

| Signal | Width | Description |
|------|------|------------|
| clk | 1 bit | System clock |
| rst | 1 bit | Reset |
| baud_clk | 1 bit | Generated baud clock |

---

## 🧪 Simulation Steps

```bash
iverilog -o baud_sim tb_baud.v baud.v
vvp baud_sim
gtkwave dump.vcd
