# 8 Bit Register

## 📘 Description
An 8-bit register stores binary data and updates its output on a clock edge.

---

## 🧠 Design Concept
- **Type:** Sequential Logic
- Built using D flip-flops
- Used for temporary data storage

---

## 📥 Inputs & 📤 Outputs

| Signal | Width | Description |
|------|------|------------|
| clk | 1 bit | Clock |
| rst | 1 bit | Reset |
| D | 8 bits | Data input |
| Q | 8 bits | Stored output |

---

## 🧪 Simulation Steps

```bash
iverilog -o reg8_sim tb_reg8.v reg8.v
vvp reg8_sim
gtkwave dump.vcd
