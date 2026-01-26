# D Flip-Flop

## 📘 Description
A D flip-flop stores one bit of data on a clock edge.

---

## 🧠 Design Concept
- **Type:** Sequential Logic
- Edge-triggered storage

---

## 📥 Inputs & 📤 Outputs

| Signal | Width | Description |
|------|------|------------|
| D | 1 bit | Data input |
| clk | 1 bit | Clock |
| Q | 1 bit | Output |

---

## 🧪 Simulation Steps

```bash
iverilog -o dff_sim tb_dff.v dff.v
vvp dff_sim
gtkwave dump.vcd
