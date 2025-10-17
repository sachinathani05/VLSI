# 🧩 CMOS Inverter (Cadence Virtuoso)


## 🧠 Overview

The **CMOS inverter** is the basic building block of digital integrated circuits.  
It inverts the input logic level using a **complementary pair** of MOSFETs — a **PMOS** and an **NMOS**.

---

## ⚙️ Design Description

### 🔹 Transistor-Level Schematic

| Component | Type | Connection |
|------------|------|-------------|
| PMOS | Pull-up | Source → VDD, Drain → Output |
| NMOS | Pull-down | Source → GND, Drain → Output |
| Both Gates | Connected → Input |

When **Vin = 0**, PMOS conducts and NMOS is OFF → **Vout = High**  
When **Vin = 1**, NMOS conducts and PMOS is OFF → **Vout = Low**

<p align="center">
  <img src="schematic/cmos_inv_schematic.png" width="500">
</p>

---
