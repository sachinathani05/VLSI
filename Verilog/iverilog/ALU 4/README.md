# 4-Bit ALU

## 📘 Description
A 4-bit Arithmetic Logic Unit performs arithmetic and logical operations based on control signals.

---

## 🧠 Design Concept
- **Type:** Combinational Logic
- Central processing unit building block

---

## 📥 Inputs & 📤 Outputs

| Signal | Width | Description |
|------|------|------------|
| A, B | 4 bits | Operands |
| Sel | 2 bits | Operation select |
| Y | 4 bits | Output |

---

## 🧪 Simulation Steps

```bash
iverilog -o alu_sim tb_alu.v alu.v
vvp alu_sim
gtkwave dump.vcd
