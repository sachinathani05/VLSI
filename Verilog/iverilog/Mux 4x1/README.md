# 4x1 Multiplexer

## 📘 Description
Selects one of four inputs based on select lines.

---

## 🧠 Design Concept
- **Type:** Combinational Logic
- Data routing element

---

## 📥 Inputs & 📤 Outputs

| Signal | Width | Description |
|------|------|------------|
| I0–I3 | 1 bit | Inputs |
| S | 2 bits | Select |
| Y | 1 bit | Output |

---

## 🔢 Truth Table

| S | Y |
|---|---|
| 00 | I0 |
| 01 | I1 |
| 10 | I2 |
| 11 | I3 |

---

## 🧪 Simulation Steps

```bash
iverilog -o mux_sim tb_mux4x1.v mux4x1.v
vvp mux_sim
gtkwave dump.vcd
