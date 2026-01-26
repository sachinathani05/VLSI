# 1 Bit Full Adder

## 📘 Description
A 1-bit full adder is a fundamental combinational circuit that adds two binary bits along with a carry-in and produces a sum and carry-out.

---

## 🧠 Design Concept
- **Type:** Combinational Logic
- Performs binary addition
- Forms the building block for multi-bit adders and ALUs

---

## 📥 Inputs & 📤 Outputs

| Signal | Width | Description |
|------|------|------------|
| A | 1 bit | First operand |
| B | 1 bit | Second operand |
| Cin | 1 bit | Carry input |
| Sum | 1 bit | Sum output |
| Cout | 1 bit | Carry output |

---

## 🔢 Truth Table

| A | B | Cin | Sum | Cout |
|---|---|-----|-----|------|
| 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 1 | 0 |
| 0 | 1 | 0 | 1 | 0 |
| 0 | 1 | 1 | 0 | 1 |
| 1 | 0 | 0 | 1 | 0 |
| 1 | 0 | 1 | 0 | 1 |
| 1 | 1 | 0 | 0 | 1 |
| 1 | 1 | 1 | 1 | 1 |

---

## 🧪 Simulation Steps

```bash
iverilog -o fa_sim tb_full_adder.v full_adder.v
vvp fa_sim
gtkwave dump.vcd
