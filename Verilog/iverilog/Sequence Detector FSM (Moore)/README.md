# Sequence Detector FSM (Moore)

## 📘 Description
Detects a specific bit pattern using a Moore finite state machine.

---

## 🧠 Design Concept
- **Type:** Sequential Logic (FSM)
- Output depends only on current state

---

## 📥 Inputs & 📤 Outputs

| Signal | Width | Description |
|------|------|------------|
| clk | 1 bit | Clock |
| rst | 1 bit | Reset |
| in | 1 bit | Serial input |
| out | 1 bit | Sequence detected |

---

## 🧪 Simulation Steps

```bash
iverilog -o fsm_sim tb_fsm.v fsm.v
vvp fsm_sim
gtkwave dump.vcd
