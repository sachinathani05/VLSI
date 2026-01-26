# 4-Bit Synchronous Counter

## 📘 Description
A synchronous counter increments its count value on every clock edge, with all flip-flops triggered simultaneously.

---

## 🧠 Design Concept
- **Type:** Sequential Logic
- Uses D flip-flops
- Clock-driven counting mechanism

---

## 📥 Inputs & 📤 Outputs

| Signal | Width | Description |
|------|------|------------|
| clk | 1 bit | Clock input |
| rst | 1 bit | Reset |
| count | 4 bits | Counter output |

---

## 🔢 State Table

| Clock | Reset | Count |
|------|------|--------|
| ↑ | 0 | Increment |
| ↑ | 1 | 0000 |

---

## 🧪 Simulation Steps

```bash
iverilog -o counter_sim tb_counter.v counter.v
vvp counter_sim
gtkwave dump.vcd
