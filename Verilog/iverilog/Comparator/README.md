# Comparator

## 📘 Description
Compares two binary numbers and outputs relational results.

---

## 🧠 Design Concept
- **Type:** Combinational Logic
- Used in sorting and control logic

---

## 📥 Inputs & 📤 Outputs

| Signal | Width | Description |
|------|------|------------|
| A, B | n bits | Inputs |
| GT | 1 bit | A > B |
| LT | 1 bit | A < B |
| EQ | 1 bit | A = B |

---

## 🧪 Simulation Steps

```bash
iverilog -o comp_sim tb_comp.v comp.v
vvp comp_sim
gtkwave dump.vcd
