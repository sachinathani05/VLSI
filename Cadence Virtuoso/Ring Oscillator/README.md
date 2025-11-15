# 3-Stage CMOS Ring Oscillator (GPDK090 | Cadence Virtuoso)

## 📘 Overview
This project contains the **schematic**, **testbench**, and **simulation results** for a **3-stage CMOS ring oscillator** designed using **Cadence Virtuoso** with the **GPDK090** PDK.

A ring oscillator consists of an **odd number of inverters** connected in a loop. Due to propagation delay and inversion, the circuit cannot settle and therefore oscillates.

---

# 🧠 1. Background Theory

## 🔁 What Is a Ring Oscillator?
A **ring oscillator** is made using an odd number of inverters. The output of the final inverter feeds back into the input of the first one.

INV1 → INV2 → INV3 → (feedback to INV1)


It oscillates because each inverter introduces delay and inversion, preventing the loop from stabilizing.

---

## 🧮 Oscillation Frequency

For N inverters, each having propagation delay \( t_p \):

\[
f_{osc} = \frac{1}{2 N t_p}
\]

For a **3-stage** ring oscillator:

\[
f_{osc} = \frac{1}{6 t_p}
\]

Frequency increases with:
- Larger transistor sizes  
- Higher VDD  
- Lower load capacitance  
- Faster process corners  
