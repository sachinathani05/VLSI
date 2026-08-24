# 45nm Analog IC Design — GPDK045

**Process:** GPDK045 v5.0 · 45nm · VDD = 1.2V (OTA) / 1.8V (LDO)  
**Tool stack:** Cadence Virtuoso IC615 · Spectre MMSIM121 · ADE L / ADE XL · Assura DRC / LVS / RCX  
**OS:** CentOS 6 32-bit Linux · VMware Workstation Pro

---

## Projects

| # | Project | Status | Flow Completed |
|---|---|---|---|
| 01 | [Two-Stage Miller-Compensated OTA](Project_01_Two_Stage_OTA_45nm/) | ✅ Complete | Schematic → DC/AC/Transient/Noise/CMRR/PSRR → Corner sweep (9 PVT) → Layout → DRC/LVS/PEX signoff · M6 series-chain defect found and root-caused |
| 02 | [OTA_LDO Error Amplifier](Project_02_OTA_LDO_Error_Amplifier/) | ✅ Complete | Schematic → Layout → DRC (0 violations) → LVS (2 waivers) → STB verified: 79.1 dB · 46.87 MHz GBW · 77.5° PM · M6/M7 parallel strapping fix |
| 03 | [1.2V LDO Voltage Regulator](Project_03_LDO_Voltage_Regulator/) | ✅ Complete | Full sub-system: OTA_LDO + MP pass array + compensation network → Schematic STB (46.57°–74.99° across 100µA–50mA) → Layout → DRC/LVS → C-only PEX → Post-layout STB (43.1°–73.8° all 9 PVT corners) |
| 04 | [6T SRAM Bit-Cell & 8×8 Array + Read Path](Project_04_6T_SRAM%20_Bit-Cell_Array_(8×8)/) | ✅ Complete | SNM butterfly curves · Read/Write margin · Monte Carlo yield · DRC/LVS · Pre/post-layout · Sense amp · Precharge/EQ · Full 8×8 read-path integration (schematic + PEX) |
| 05 | StrongARM Latch | 🔜 Planned | Metastability · Common-centroid layout · PEX timing |
| 06 | Switched-Capacitor Integrator | 🔜 Planned | Charge injection · Capacitor matching · MOM layout |

---

## Key Results at a Glance

### Project 01 — Two-Stage OTA

| Parameter | Result |
|---|---|
| DC gain | 75.6 dB |
| GBW | 57.5 MHz |
| Phase margin (TT/27°C) | 60.9° |
| Slew rate (rising) | 64.5 V/µs |
| CMRR | 76.4 dB |
| PSRR | 164.4 dB |
| Thermal noise floor | 9.5 nV/√Hz |
| DRC | ✅ 0 violations |
| LVS | ✅ Matched (2 waivers) |
| PEX | ✅ Extracted — M6 series-chain defect root-caused |

### Project 02 — OTA_LDO Error Amplifier

| Parameter | Result |
|---|---|
| DC gain | 79.1 dB |
| GBW | 46.87 MHz |
| Phase margin | 77.5° |
| DRC | ✅ 0 violations |
| LVS | ✅ Matched (2 waivers) |
| M6/M7 layout defect | ✅ Fixed — parallel strapping applied |

### Project 03 — 1.2V LDO Voltage Regulator

| Parameter | Result |
|---|---|
| VOUT regulated | 1.200V |
| Load range | 100µA – 50mA |
| Schematic PM (worst load) | 46.57° @ 100µA |
| Schematic PM (full load) | 74.99° @ 50mA |
| Post-layout PM (all 9 PVT) | 43.1°–73.8° — all pass |
| Line regulation | 0.19 mV/V |
| Load regulation | 0.094 mV (0→50mA) |
| PSR @ 100Hz | 71.8 dB |
| Dropout @ 50mA | ~220mV |
| DRC | ✅ 0 violations |
| LVS | ✅ Matched (5 waivers) |

### Project 04 — 6T SRAM Bit-Cell & 8×8 Array

| Parameter | Result |
|---|---|
| Final sizing | CR=2.5 (PD=450nm/PG=180nm) · PR=0.67 (PU=120nm) |
| Read SNM — pre / post-layout | 140.0mV / 138.6mV |
| Hold SNM — pre / post-layout | 303mV / 303.1mV |
| Write Margin — pre / post-layout | 0.703V / 0.703V |
| Read SNM worst corner | SF @ 125°C = 53.6mV (documented limitation) |
| Monte Carlo yield (200 runs, SNM > 100mV) | Mean=120.7mV · σ=10.1mV · 98.5% |
| 8×8 array BL capacitance / access time | 3.22fF / 11.2ps |
| Full read-path integration | ✅ PASSED — schematic + post-layout (precharge_eq + 8×8 array + sense_amp) |
| DRC (bit-cell + array) | ✅ 0 violations |
| LVS (bit-cell + array) | ✅ Matched |

---

## Design Flow Progression

```
Project 01          Project 02              Project 03
─────────           ─────────────────────   ────────────────────────────────
Schematic           Schematic               System integration
    │               (adds real PDK              (OTA_LDO + MP pass + network)
    ▼               Cc/Rz devices)          Schematic STB sweep
DC/AC/Transient         │                   Layout floorplan
Noise/CMRR/PSRR         ▼                   DRC/LVS signoff
    │               Layout                  C-only PEX extraction
    ▼               (ABBA, parallel         Netlist correction (6 fix types)
Corner sweep        strapping M6/M7,        Post-layout STB (9 PVT corners)
(9 PVT, ADE XL)     Cc 4×4 array, Rz)
    │                   │
    ▼                   ▼
Layout              DRC/LVS signoff
DRC/LVS/PEX         STB convergence
Post-PEX debug      solution (V_TEMP
(M6 series chain    + L_TEMP + inner
 root-caused)        iprobe pattern)
```

---

## Recurring Themes Across Projects

| Finding | Project 1 | Project 2 | Project 3 |
|---|---|---|---|
| Multi-finger series-chain defect | Found, root-caused | Fixed before LVS | N/A (single-finger pass device) |
| Bistable DC convergence | At schematic level | V_TEMP+L_TEMP solution developed | Same solution reused + extended |
| LVS vs extractor discrepancy | VIN+_avConflict | Pin purpose labels | C-only PEX strips designed resistors |
| 32-bit model substitution | g45ncap1/g45rspp | Same | g45rnspp/g45rspp/g45ncap1 all |
| Global `gnd!` for substrate taps | Documented | Applied | Applied + Ntap for Nwell too |

---

## Environment

| Item | Detail |
|---|---|
| Schematic / Layout | Cadence Virtuoso IC615 |
| Simulator | Spectre MMSIM121 (32-bit) |
| Simulation environment | ADE L · ADE XL |
| DRC / LVS / PEX | Assura 4.1 (DRC · LVS · RCX) |
| PDK | GPDK045 v5.0 · 45nm |
| OS | CentOS 6 32-bit · VMware Workstation Pro |
| Model workaround | PTM BSIM4 redirect — all Verilog-A models bypassed for 32-bit compatibility |
