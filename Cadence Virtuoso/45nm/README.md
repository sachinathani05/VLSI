# 45nm Cadence Virtuoso — Advanced Analog IC Design

Process node: GPDK045 45nm · VDD = 1.2V · Tool: Cadence Virtuoso IC615

---

## Projects

| # | Project | Status | Key Techniques |
|---|---------|--------|----------------|
| 1 | [Two-Stage Miller-Compensated OTA](Project_01_Two_Stage_OTA_45nm/) | ✅ Completed | AC/DC/transient · Noise · CMRR · PSRR · Corner sweep · Full layout · DRC/LVS/PEX signoff |
| 2 | Low-Dropout Regulator (LDO) | 🟡 In Progress | Full IP sub-system · Loop stability · Load transient |
| 3 | 6T SRAM Bit-Cell Array | 🔜 Planned | SNM butterfly curves · DRC/LVS · Yield analysis |
| 4 | StrongARM Latch | 🔜 Planned | Metastability · Common-centroid layout · PEX timing |
| 5 | Switched-Capacitor Integrator | 🔜 Planned | Charge injection · Capacitor matching · MOM layout |

---

## Environment

| Item | Detail |
|------|--------|
| Tool | Cadence Virtuoso IC615 · Spectre MMSIM121 · ADE L / ADE XL |
| PDK | GPDK045 v5.0 · 45nm |
| DRC/LVS | Cadence PVS |
| PEX | Cadence QRC |
| OS | CentOS 6 32-bit · VMware Workstation Pro |
