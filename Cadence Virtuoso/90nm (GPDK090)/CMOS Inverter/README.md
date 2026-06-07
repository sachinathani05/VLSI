# CMOS Inverter (Cadence Virtuoso - GPDK090 90nm)

## Overview

The CMOS inverter is the fundamental building block of digital integrated circuits.
It inverts the input logic level using a complementary pair of MOSFETs - a PMOS and an NMOS.

---

## Design Description

### Transistor-Level Schematic

| Component | Type | Connection |
|-----------|------|------------|
| PMOS | Pull-up | Source to VDD, Drain to Output |
| NMOS | Pull-down | Source to GND, Drain to Output |
| Both Gates | Connected to Input | — |

When Vin = 0, PMOS conducts and NMOS is OFF → Vout = High
When Vin = 1, NMOS conducts and PMOS is OFF → Vout = Low

![Layout](Design%20and%20Layout/CMOS_Inv.jpg)

---

## Simulation Results

### DC Transfer Characteristic
- Switching threshold VM measured via parametric sweep
- VM shifts with W/L ratio of PMOS/NMOS
- Symmetric VM achieved at PMOS/NMOS width ratio of approximately 2:1

### Transient Characteristic
- Rise and fall propagation delays measured at VDD/2 crossing
- Waveform confirms clean logic-level switching
- Results consistent with GPDK090 90nm expected performance

---

## Parametric Sweep - W/L Ratio vs Switching Threshold

Performed in both Cadence Virtuoso and LTSpice for cross-tool validation.

### Cadence Results
- W/L sweep performed across PMOS width ratio 1 to 5
- Switching threshold VM increases with larger PMOS width
- Parametric sweep confirms theoretical VM = VDD/2 at balanced sizing

![Parametric Sweep](Threshold%20Voltage%2C%20Parametric%20Sweep%20%26%20Tool%20Comparison/Cadence/Parametric%20sweep%20of%20transistor%20WL%20ratio.jpg)

![Switching Threshold](Threshold%20Voltage%2C%20Parametric%20Sweep%20%26%20Tool%20Comparison/Cadence/Switching%20Threshold%20(VM)%20.jpg)

### LTSpice Cross-Check
- Same inverter schematic reproduced in LTSpice
- DC and transient characteristics verified against Cadence results
- W/L sweep CSV data exported and compared
- Results consistent between both tools - validates simulation accuracy

---

## DRC and LVS

- Layout drawn in Cadence Virtuoso Layout Editor
- DRC run - design rule violations checked and cleared
- LVS run - layout netlist matched against schematic netlist
- Full verification sign-off achieved

![DRC LVS](DRC%20%26%20LVS/CMOS%20Layout.jpg)

---

## Tools Used

| Tool | Purpose |
|------|---------|
| Cadence Virtuoso Schematic Editor | Schematic capture |
| Cadence Virtuoso Layout Editor | Physical layout |
| Cadence ADE L + Spectre | Simulation and waveform analysis |
| LTSpice | Cross-tool validation |
| GPDK090 90nm PDK | Process design kit |

---

## Key Learnings

- CMOS complementary operation and switching threshold theory
- Impact of W/L ratio on VM and propagation delay
- Cross-tool validation between Cadence and LTSpice
- DRC and LVS sign-off flow in Cadence Virtuoso
