# Two-Stage Miller-Compensated OTA — GPDK045 45nm

**Tool:** Cadence Virtuoso IC615 · Spectre MMSIM121 · ADE L / ADE XL · PVS (DRC/LVS) · QRC (PEX)  
**PDK:** GPDK045 v5.0 · 45nm · VDD = 1.2V · CL = 10pF  
**OS:** CentOS 6 32-bit Linux · VMware Workstation Pro

---

## Table of Contents

1. [Circuit Topology](#1-circuit-topology)
2. [Device Sizing](#2-device-sizing)
3. [DC Operating Point](#3-dc-operating-point)
4. [AC Simulation — Gain & Stability](#4-ac-simulation--gain--stability)
5. [Transient Simulation — Slew Rate & Settling](#5-transient-simulation--slew-rate--settling)
6. [Noise Analysis](#6-noise-analysis)
7. [CMRR Simulation](#7-cmrr-simulation)
8. [PSRR Simulation](#8-psrr-simulation)
9. [Corner Sweep — ADE XL](#9-corner-sweep--ade-xl)
10. [Monte Carlo & Offset Budget](#10-monte-carlo--offset-budget)
11. [Layout](#11-layout)
12. [Results Summary](#12-results-summary)
13. [Design Limitations & Engineering Discussion](#13-design-limitations--engineering-discussion)
14. [Environment & 32-bit Workarounds](#14-environment--32-bit-workarounds)

---

## 1. Circuit Topology

A two-stage Miller-compensated OTA is one of the most fundamental analog building blocks in IC design — appearing inside ADCs, PLLs, LDOs, and switched-capacitor filters. Two gain stages are required because a single differential pair at 45nm gives only ~25–35 dB intrinsic gain (gm×ro), well below the 60 dB target. Cascading a second common-source stage multiplies the gain:

```
Av_total = (gm1 × Ro1) × (gm6 × Ro2)
```

Two stages introduce two poles, creating a phase-shift problem. Miller compensation places Cc from VOUT back to the first-stage output, creating dominant-pole splitting: p1 is pushed to very low frequency, p2 is pushed high, and phase margin is recovered.

```
Signal:  VIN+ → M1 → NET_A → M3/M4 mirror → NET_B → M6 gate → VOUT
Bias:    IREF → M8 (diode-connected) → BIAS → M5 gate, M7 gate
Miller:  VOUT → Cc → Rz → NET_B    (feedback compensation path only)
```

> **Critical topology note:** M6 gate connects **directly** to NET_B. Rz and Cc form a separate parallel feedback path. M6 gate is **not** in series with Rz. This is the single most common wiring error in Miller OTA design — connecting M6 gate to the node between Rz and Cc removes M6's DC bias path and collapses VOUT to near VSS.

| Equation | Defines |
|---|---|
| `GBW = gm1 / (2π·Cc)` | Unity-gain bandwidth — set by input pair and compensation cap |
| `p1 = 1 / (gm6·Cc·Ro1·Ro2)` | Dominant pole — pushed very low by Miller effect |
| `p2 = gm6 / (2π·CL)` | Non-dominant pole — pushed high by Miller effect |
| `p2 > 2.2 × GBW` | Condition for PM > 60° |
| `fz = gm6 / (2π·Cc)` | RHP zero from Cc alone — removed by Rz |
| `Rz_ideal = 1/gm6` | Nulling resistor value to push zero to infinity |

![OTA Schematic](OTA_Scehmatic.jpg)
*Full OTA schematic with device labels, net names (NET_A, NET_B, TAIL, BIAS, VOUT), and Rz-Cc feedback path*

---

## 2. Device Sizing

| Device | Type | W | L | Role | Key Point |
|---|---|---|---|---|---|
| M1 | NMOS nmos1v | 4 µm | 180 nm | Diff pair (+) input | VIN+ terminal |
| M2 | NMOS nmos1v | 4 µm | 180 nm | Diff pair (−) input | VIN− terminal |
| M3 | PMOS pmos1v | 6 µm | 180 nm | Active load — diode-connected | Sets mirror reference |
| M4 | PMOS pmos1v | 6 µm | 180 nm | Active load — current mirror | First-stage output load |
| M5 | NMOS nmos1v | 4 µm | 180 nm | Tail current source | Sets Id for M1/M2 |
| M6 | PMOS pmos1v | 250 µm | 180 nm | Second-stage amp (CS) | Dominant gm6 device |
| M7 | NMOS nmos1v | 50 µm | 180 nm | Second-stage load | Current source at VOUT |
| M8 | NMOS nmos1v | 4 µm | 180 nm | Bias reference | Diode-connected, generates BIAS |
| Cc | analogLib cap | 1.35 pF | — | Miller compensation | Sets p1 and GBW |
| Rz | analogLib res | 100 Ω | — | Nulling resistor | Removes RHP zero; ideal = 1/gm6 = 83 Ω |
| IREF | analogLib idc | 100 µA | — | Bias current | Testbench only |
| CL | analogLib cap | 10 pF | — | Load capacitor | Testbench only; drives p2 requirement |

> **mimcap note:** mimcap was explored for Cc but is impractical — GPDK045 mimcap max cell is 5.6µm × 5.6µm giving ~32 fF/unit, requiring multiplier=32 for ~1 pF (barely sufficient, poor layout density of 0.755 fF/µm²). `nmoscap1v` is used in layout as the on-chip capacitor implementation.

---

## 3. DC Operating Point

**Testbench:** Unity-gain buffer configuration (VOUT → VIN+, VIN− = 0.6V DC, VDD = 1.2V).  
**Purpose:** Verify every transistor is in the correct operating region before running any AC or transient simulation. A device in triode has significantly lower output impedance and will degrade gain.

![AC & DC Testbench Schematic](OTA_AC&DC_TB_Scehmatic.jpg)
*AC and DC testbench — unity-gain buffer with iprobe inserted in feedback wire for STB analysis*

### 3.1 Device Operating Points (TT, 27°C)

| Device | Id | Vgs (V) | Vds (V) | gm (mA/V) | Region |
|---|---|---|---|---|---|
| M1 | 38.1 µA | 0.522 | 0.504 | 0.602 | ✅ Saturation |
| M2 | 37.98 µA | 0.522 | 0.529 | 0.600 | ✅ Saturation |
| M3 | 38.06 µA | −0.618 | −0.618 | 0.327 | ✅ Saturation |
| M4 | 37.98 µA | −0.618 | −0.593 | 0.327 | ✅ Saturation |
| M5 | 76.05 µA | 0.568 | 0.078 | 0.756 | ⚠️ **Triode** |
| M6 | 1.254 mA | −0.593 | −0.600 | 12.07 | ✅ Saturation |
| M7 | 1.254 mA | 0.568 | 0.600 | 15.19 | ✅ Saturation |
| M8 | 99.93 µA | 0.568 | 0.568 | 1.211 | ✅ Saturation |

### 3.2 Key Node Voltages

| Node | Voltage | Significance |
|---|---|---|
| VDD | 1.200 V | Supply rail |
| VOUT | ~0.600 V | Mid-rail ✅ correct for unity-gain with VIN−=0.6V |
| BIAS | 0.568 V | M5 and M7 gate bias from M8 diode |
| TAIL | 0.078 V | M1/M2 common source — very low due to headroom limit |
| NET_A | 0.582 V | Diode-connected PMOS load output |
| NET_B | 0.607 V | First-stage output / M6 gate input |

### 3.3 M5 in Triode — Why It Happens and Why It Was Accepted

M5 operates in triode (Vds = 78 mV < Vdsat = 116 mV). This is a fundamental 1.2V supply headroom limitation:

```
Available headroom for M5: VDD − Vgs(M1) − Vds_needed(M5) = 1.2V − 0.522V − needed = ~78 mV
Vdsat(M5) = 116 mV  →  Triode
```

Accepted because: triode M5 only degrades CMRR (low tail impedance = poor common-mode rejection). All signal-path devices remain in saturation. Measured CMRR = 76.4 dB still passes the 60 dB target. Attempts to fix M5 by widening it or increasing IREF all pushed M1/M2 into subthreshold before M5 entered saturation — an unavoidable headroom conflict at 1.2V/45nm.

---

## 4. AC Simulation — Gain & Stability

### 4.1 STB Analysis Method

Spectre STB (stability) analysis inserts an `iprobe` (ideal zero-impedance current probe) into the feedback wire. The iprobe does not disturb the DC operating point but allows Spectre to inject a test signal and measure the complex loop gain T(f) at every frequency. This is the correct method for measuring open-loop gain and phase margin of a closed-loop circuit — manually breaking the loop can create a different DC operating point at the break point, giving incorrect phase margin readings.

**ADE L output expressions used:**

| Expression | Measures |
|---|---|
| `getData("loopGain" ?result "stb")` | Complex loop gain vs. frequency (Bode plot) |
| `cross(mag(getData("loopGain")), 1, 1, "falling")` | GBW: frequency where gain crosses 0 dB falling |
| `180 + phaseMargin(getData("loopGain" ?result "stb"))` | Phase margin in degrees |

> **Why add 180 to phaseMargin():** `phaseMargin()` returns the phase at the GBW crossing frequency (e.g. −119.1°). Phase margin = distance from −180° = 180 + (−119.1) = **60.9°**.

### 4.2 AC Results (TT, 27°C)

| Parameter | Measured | Target | Status |
|---|---|---|---|
| DC open-loop gain | **75.6 dB** | > 60 dB | ✅ PASS |
| GBW (unity-gain BW) | **57.5 MHz** | > 100 MHz | ⚠️ Below target |
| Phase margin | **60.9°** | > 60° | ✅ PASS |
| Cc | 1.35 pF | — | — |
| Rz | 100 Ω | — | — |
| CL | 10 pF | — | — |

### 4.3 GBW Limitation — Why 100 MHz Was Not Achieved

The GBW target of 100 MHz is a fundamental constraint at 1.2V/45nm. Three compounding factors:

**1. gm1 headroom ceiling**  
M1/M2 at W=4µm, Id=38µA → gm1=601µA/V. Increasing W to boost gm1 lowers Vov, pushing M1/M2 toward subthreshold (Vgs=522mV, Vth≈491mV — only 31mV margin). The tail node provides insufficient Vgs headroom once width exceeds ~10µm.

**2. Miller loading from M6**  
M6 at W=250µm has large Cgd6. Miller multiplication at NET_B effectively increases the load capacitance seen by the first stage, reducing first-stage bandwidth.

**3. p2 ceiling from CL**  
`p2 = gm6/(2π·CL) = 12.07mA / (2π × 10pF) = 192 MHz`. For PM ≥ 60°, GBW must stay below `p2/2.2 = 87 MHz`. This is the hard ceiling — GBW cannot exceed this without degrading phase margin.

### 4.4 AC Tuning Iterations

| Cc | M6 W | GBW | PM | Observation |
|---|---|---|---|---|
| 1 pF | 18 µm | 37 MHz | 11° | PM critically low; also Rz/Cc in wrong order at this stage |
| 4 pF | 18 µm | 30 MHz | 60° | PM OK but GBW too low |
| 1.5 pF | 500 µm | 90 MHz | 51° | GBW up but PM down — M6 too wide causes Miller loading |
| 2 pF | 600 µm | 60 MHz | 67.6° | Near target; GBW still below 100 MHz |
| **1.35 pF** | **250 µm** | **57.5 MHz** | **60.9°** | **Final — best achievable tradeoff** |

![Bode Plot - AC Loop Gain](OTA_AC.jpg)
*Loop gain magnitude (dB) and phase (°) vs. frequency. DC gain 75.6 dB, GBW crossing at 57.5 MHz, phase at GBW = −119.1°, PM = 60.9°*

---

## 5. Transient Simulation — Slew Rate & Settling

### 5.1 Testbench Configuration

| Parameter | Value | Reason |
|---|---|---|
| Input source | vpulse on VIN− | Step input while VIN+ = VOUT (unity-gain buffer) |
| V1 / V2 | 0.3V / 0.9V | ±0.3V symmetric swing around 0.6V mid-rail |
| Rise/fall time | 1 ns | Much faster than OTA SR — ensures slew limiting is visible |
| Period (SR measurement) | 400 ns | Captures multiple cycles |
| Period (settling measurement) | 5 µs | Necessary — falling edge did not settle within 400 ns |
| Simulation time | 6 µs | Captures one full 5 µs period + margin |

### 5.2 Slew Rate Measurement

**Method 1 — Two-marker manual:**  
SR_rising = (0.804 − 0.340)V / (19.45 − 12.0)ns = **62.2 V/µs**

**Method 2 — `deriv()` calculator (preferred — finds true instantaneous peak):**
```
deriv(VT("/VOUT"))
```
Places marker at peak of dV/dt waveform.

### 5.3 Results

| Parameter | Measured | Target | Status |
|---|---|---|---|
| SR rising (deriv peak) | **64.5 V/µs** | > 20 V/µs | ✅ PASS |
| SR falling (deriv peak) | **55 V/µs** | > 20 V/µs | ✅ PASS |
| Settling time rising (0.1%) | **18.6 ns** | < 100 ns | ✅ PASS |
| Settling time falling (0.1%) | **223 ns** | < 100 ns | ❌ FAIL |
| Overshoot (rising) | ~3.3% | — | Consistent with PM = 60.9° |

### 5.4 Asymmetry Analysis — Why Rising ≠ Falling

**Rising edge:** M6 (PMOS, W=250µm) actively sources current into CL. Under large-signal drive, M6 can source well above its DC bias current of 1.254 mA. The loop closes quickly → 18.6 ns settling.

**Falling edge:** M6 turns off. Only M7 (NMOS, W=50µm, Id=1.254 mA) pulls VOUT down. Theoretical `SR_falling = Id_M7 / CL = 1.254mA / 10pF = 125 V/µs`. The fast initial drop (55 V/µs) confirms M7 pulls hard. But then a slow exponential tail dominates for 200+ ns.

### 5.5 Pole-Zero Doublet — Root Cause of Slow Falling Tail

The Rz-Cc network creates a LHP zero to cancel the Miller pole (p1). Perfect cancellation requires `Rz = 1/gm6 = 83 Ω` exactly. Rz=100 Ω is a standard resistor value — the mismatch leaves a residual uncancelled pole-zero pair called a **doublet**. This doublet creates a second time constant in the step response: the output settles quickly via the dominant pole, then drifts slowly via the doublet time constant.

```
τ_doublet ≈ 1/GBW = 1/57.5MHz = 17 ns per time constant
0.1% settling ≈ 7τ = 7 × 17 ns = 119 ns  (measured: 223 ns — same order)
```

This is not a design error but a known tradeoff: exact Rz=1/gm6 cancellation would improve falling settling but gm6 varies with bias and corner, so a fixed Rz can never perfectly cancel at all conditions.

![Transient Full Waveform](Vpulse_full_waveform.jpg)
*Full transient — VOUT (green) and VIN (red). Fast rising edges, slow exponential falling tails visible.*

![Transient One Period Zoom](oneperiod_Vpulse.jpg)
*Single period zoom — rising edge overshoot (~3.3%), fast settling on rising side, slow doublet tail on falling side.*

---

## 6. Noise Analysis

### 6.1 Input-Referred Noise Concept

Every transistor generates random current noise. Output noise is the sum of all internal contributions amplified to the output. **Input-referred noise** divides output noise by the gain at each frequency, collapsing all sources to one equivalent noise at the input. This allows direct SNR comparison: if input noise is 10 nV/√Hz and signal bandwidth is B Hz, total RMS noise = 10√B nV.

### 6.2 Three Regions of the Noise Curve

| Region | Frequency Range | Physical Source | This Design |
|---|---|---|---|
| Flicker (1/f) | 1 Hz – 1.4 MHz | Charge carriers trapped/released at gate oxide interface defects. Power ∝ 1/f. | 11.39 µV/√Hz at 1 Hz, falling at −10 dB/decade |
| Thermal floor | 1.4 MHz – ~20 MHz | Random thermal carrier collisions in MOSFET channel. `Sn = 4kT(2/3)/gm1`. Flat. | **9.5 nV/√Hz** — set by gm1 = 601 µA/V |
| Noise gain peaking | Above ~20 MHz | Artifact: as gain rolls off above GBW, input-referred = output/gain rises. Not real noise. | Rises to 91.3 nV/√Hz near 100 MHz — irrelevant |

### 6.3 Measured Results

| Parameter | Value |
|---|---|
| Input-referred noise at 1 Hz | 11.39 µV/√Hz |
| Thermal noise floor | 9.5 nV/√Hz |
| Flicker corner frequency | **1.4 MHz** |
| Integrated RMS (1 Hz – 100 MHz) | ~107 µV |

**Flicker corner calculation:**
```
fc = (noise_at_1Hz / thermal_floor)² × 1Hz
   = (11391 nV/√Hz ÷ 9.5 nV/√Hz)² × 1Hz
   = 1199² × 1Hz = 1.44 MHz ≈ 1.4 MHz
```

### 6.4 Why 45nm Has High Flicker Corner

At 45nm, gate oxide is ~1.5 nm — one or two atomic layers. This creates more interface defects per unit area and enables quantum tunnelling into a larger trap volume, both increasing the flicker noise coefficient KF:

| Node | Oxide thickness | Typical NMOS flicker corner |
|---|---|---|
| 350 nm | ~8 nm | ~100 Hz – 1 kHz |
| 180 nm | ~4 nm | ~1 kHz – 10 kHz |
| 90 nm | ~2 nm | ~100 kHz – 1 MHz |
| **45 nm (this design)** | **~1.5 nm** | **~1 MHz – 5 MHz** |
| 28 nm (HfO2 high-k) | ~1 nm | ~10 MHz – 100 MHz |

### 6.5 Application Suitability

| Application | Signal frequency | Verdict |
|---|---|---|
| ECG / EEG (medical) | 0.1 Hz – 200 Hz | ❌ Deep in flicker region — needs chopper or 180 nm process |
| Audio amplifier | 20 Hz – 20 kHz | ❌ Flicker dominated — use PMOS input pair or older process |
| Baseband (WiFi/BT) | 1 MHz – 50 MHz | ✅ Near/above flicker corner — acceptable |
| RF receiver (2.4 GHz) | 2.4 GHz | ✅ Far above flicker — thermal floor only at 9.5 nV/√Hz |

![Noise Waveform](OTA_Noise_Waveform.jpg)
*Log-log input-referred noise: 1/f slope below 1.4 MHz, flat thermal floor at 9.5 nV/√Hz, noise gain peaking above 20 MHz.*

---

## 7. CMRR Simulation

**CMRR = Adm / Acm** — how much better the OTA amplifies a differential signal compared to a common-mode signal applied to both inputs simultaneously.

### 7.1 Testbench Setup

1. Break unity-gain feedback (disconnect VOUT from VIN+)
2. Connect a single vac source (DC=0.6V, AC=1) to **both** VIN+ and VIN− simultaneously
3. VOUT connects only to CL (open loop)
4. Run AC: 1 Hz – 10 MHz, 20 pts/decade
5. Plot VOUT in dB20 → this is Acm(f)

### 7.2 Results

| Parameter | Value | Target | Status |
|---|---|---|---|
| Acm at 1 kHz | −0.807 dB | — | Recorded |
| Adm (DC open-loop) | 75.6 dB | — | From AC simulation |
| **CMRR at 1 kHz** | **76.4 dB** | > 60 dB | ✅ PASS |

`CMRR = Adm − Acm = 75.6 − (−0.807) = 76.4 dB`

Acm is nearly flat at −0.807 dB from DC to ~100 kHz, then rolls off. The near-unity low-frequency Acm is caused by M5 in triode — a triode tail current source has low output impedance and cannot suppress common-mode inputs effectively. CMRR still passes because differential gain is high enough. Above ~200 kHz, Acm rolls off and CMRR improves significantly (>110 dB at 10 MHz).

![CMRR Waveform](CMRR_waveform.jpg)
*Acm (dB) vs. frequency: flat at −0.807 dB from DC to 100 kHz, rolling off to −35 dB at 10 MHz.*

---

## 8. PSRR Simulation

**PSRR = Adm / A_supply** — how much VDD supply noise appears at the output. Real VDD rails carry switching transients, LDO ripple, and DC-DC converter noise.

### 8.1 Testbench Setup

1. Restore unity-gain feedback (VOUT → VIN+)
2. VIN− = 0.6V DC (no AC)
3. VDD: DC=1.2V, **AC magnitude=1** (perturbation on supply)
4. Run AC: 1 Hz – 10 MHz
5. Plot VOUT in **dB20** → this is A_supply(f)

> **dB20 vs dB10:** Always use `dB20 = 20·log₁₀(V)` for voltage ratios. `dB10 = 10·log₁₀(P)` is for power only. During this simulation both were plotted: dB20 gave −88.79 dB and dB10 gave −44.40 dB (exactly half). Using dB10 for PSRR gives a completely wrong answer.

### 8.2 Results

| Parameter | Value | Target | Status |
|---|---|---|---|
| A_supply at 1 kHz | −88.79 dB | — | Recorded |
| **PSRR at 1 kHz** | **164.4 dB** | > 40 dB | ✅ PASS (by large margin) |

`PSRR = 75.6 − (−88.79) = 164.4 dB`

### 8.3 Why PSRR >> CMRR

CMRR=76.4 dB, PSRR=164.4 dB — an 88 dB difference. VDD perturbation must couple through transistors to reach VOUT, and the feedback loop actively suppresses any supply-induced output error. Loop gain = 75.6 dB ≈ 6000× suppresses supply disturbances multiplicatively. Common-mode signals, by contrast, enter directly through input terminals and bypass the full loop gain benefit.

![PSRR Waveform](PSRR_Waveform.jpg)
*A_supply (dB20) vs. frequency: −88.79 dB at 1 kHz, giving PSRR = 164.4 dB.*

---

## 9. Corner Sweep — ADE XL

### 9.1 Process Corner Physical Meaning

| Corner | NMOS | PMOS | Physical Meaning | Worst Case For |
|---|---|---|---|---|
| TT | Typical | Typical | Nominal transistors — design target | Baseline |
| SS | Slow | Slow | Higher Vth, lower mobility — devices conduct less | Speed (lowest GBW) |
| FF | Fast | Fast | Lower Vth, higher mobility — devices conduct more | Stability (PM risk) |
| SF / FS | Mixed | Mixed | Not available — require 64-bit full models | Offset / matching |

### 9.2 Temperature Variable Bug

A critical ADE XL gotcha discovered during corner sweep: the global variable for temperature must be named exactly **`temperature`** (all lowercase).

- `Temperature` (capital T): passes to netlist as a named parameter (`parameters Temperature=-40`) but does NOT connect to the simulator's temperature register — which stays at its default 27°C. All 9 simulation points show identical GBW and PM.
- `temp`: ADE XL rejects with the explicit message: *"Use `temperature` in order to modify simulation temperature"*
- `temperature`: correctly maps to `simulatorOptions temp=<value>`

### 9.3 Corner Sweep Results (3 Corners × 3 Temperatures)

| Corner | Temp | GBW | Phase Margin | Status |
|---|---|---|---|---|
| TT | −40°C | 91.55 MHz | 62.66° | ✅ PASS |
| TT | 27°C | 57.11 MHz | 60.88° | ✅ PASS |
| TT | 125°C | 31.44 MHz | 61.86° | ✅ PASS |
| SS | −40°C | 87.23 MHz | 62.34° | ✅ PASS |
| SS | 27°C | 48.73 MHz | 62.30° | ✅ PASS |
| SS | 125°C | 25.55 MHz | 63.70° | ✅ PASS |
| FF | −40°C | 92.49 MHz | 61.23° | ✅ PASS |
| **FF** | **27°C** | **61.73 MHz** | **56.88°** | ❌ **FAIL** |
| **FF** | **125°C** | **35.53 MHz** | **55.68°** | ❌ **FAIL** |

GBW range across all corners/temperatures: **25.5 MHz (SS/125°C) → 92.5 MHz (FF/−40°C)** — a 3.6× spread.

### 9.4 FF Corner Failure Analysis

FF corner fails PM at 27°C and 125°C. Root cause: GBW scales faster than p2 in the FF corner.

For PM ≥ 60°, need `p2 > 2.2 × GBW`. When GBW grows faster than p2, the ratio shrinks and PM falls.

```
TT/27°C:  GBW = 57 MHz,  p2 = 192 MHz,  ratio = 3.36  →  PM = 60.9°  ✅
FF/27°C:  GBW ↑ faster,  p2 grows less,  ratio shrinks  →  PM = 56.9°  ❌
FF/125°C: PMOS gm6 degrades faster with temp than NMOS gm1  →  PM = 55.7°  ❌
```

Physical reason: PMOS is hole-based transport. Hole mobility degrades more steeply with temperature than electron mobility. At 125°C, gm6 (PMOS M6) drops proportionally more than gm1 (NMOS M1/M2), reducing the p2/GBW ratio.

**Proposed fix:** Increase Cc from 1.35 pF → 1.55 pF. This lowers GBW at all corners by ×(1.35/1.55)=0.87 without changing p2. FF/27°C GBW drops from 62 → 54 MHz, restoring PM above 60°. Trade-off: TT/27°C GBW drops from 57 → ~50 MHz.

![Loop Gain Corner Waveform - TT](LoopGain_Corner_Waveform.jpg)
*Loop gain Bode plot — corner sweep overlay. Gain and phase vs. frequency across TT/SS/FF corners.*

![Loop Gain Corner Waveform - SS/FF comparison](LoopGain_Corner_Waveform_2.jpg)
*Corner sweep — SS and FF phase margin comparison. FF corner phase margin degradation visible at GBW crossing.*

![Loop Gain Corner Waveform - Temperature sweep](LoopGain_Corner_Waveform_3.jpg)
*Corner sweep across temperatures. GBW range: 25.5 MHz (SS/125°C) to 92.5 MHz (FF/−40°C).*

![Corner Case Results Table](Corner_Case_Result.png)
*ADE XL results table: all 9 corner/temperature simulation points with GBW and phase margin values.*

---

## 10. Monte Carlo & Offset Budget

### 10.1 Why Monte Carlo Was Not Achievable

Four separate approaches were attempted on 32-bit Spectre 12.1 — all blocked:

| Attempt | Method | Error | Root Cause |
|---|---|---|---|
| 1 | ADE XL Mismatch mode default | `SPECTRE-16011: no mismatch variations` | `0.1_models/gpdk045_mos.scs` has no statistics block |
| 2 | `vary g45n1svt(vth0) std=0.004` | `SFE-874: Unexpected '('` | Parenthesis syntax not supported in 32-bit Spectre 12.1 |
| 3 | `vary g45n1svt vth0 std=0.004` | `SFE-874: Unexpected 'std'` | Space-separated syntax also not supported |
| 4 | Full models `section=mc` (has proper statistics block) | `VACOMP-1008` + Segfault | `g45n1svt` subcircuit contains Verilog-A components requiring 64-bit VACOMP compiler |

The full GPDK045 g45n1svt model is an inline subcircuit wrapping the BSIM4 core with mismatch parameters (rn1, rn2, rp1, rp2) and a poly resistor + bsource implemented in Verilog-A. These require the 64-bit Verilog-A compiler unavailable in 32-bit Spectre 12.1.

### 10.2 Pelgrom's Law — Analytical Offset Estimate

Since Monte Carlo was not achievable, input offset is estimated analytically using Pelgrom's Law:

```
σ(ΔVth) = √2 × AVT / √(W × L)
```

| Parameter | Value |
|---|---|
| AVT (NMOS, 45nm) | ~3 mV·µm |
| AVT (PMOS, 45nm) | ~4 mV·µm |

**M1/M2 contribution (NMOS differential pair):**
```
σ(ΔVth_M1M2) = √2 × 3 / √(4µm × 0.18µm) = 4.243 / 0.849 = 4.99 mV
```

**M3/M4 contribution (PMOS active load), input-referred via gm3/gm1 ratio:**
```
σ(ΔVth_M3M4) = √2 × 4 / √(6µm × 0.18µm) = 5.45 mV  →  × (gm3/gm1) = × 0.544 = 2.96 mV
```

**Total (uncorrelated — add in quadrature):**
```
σ(Vos) = √(4.99² + 2.96²) = √33.66 = 5.8 mV
3σ = 3 × 5.8 = 17.4 mV    (Target: < 5 mV)
```

### 10.3 What It Would Take to Meet 5 mV

Working backwards: need σ(Vos) < 1.67 mV, which requires M1/M2 W ≈ 100 µm (25× current size). This creates an unavoidable conflict: 100 µm M1/M2 at 38 µA would have Vov ≈ 6 mV — deep in subthreshold where Vth mismatch itself becomes unreliable. The offset spec, GBW spec, and supply voltage cannot all be simultaneously met at 45nm with 1.2V. Real products resolve this through chopper stabilisation (bypasses random offset entirely), higher-Vt devices with larger gate area per node, or relaxed offset spec.

---

## 11. Layout

### 11.1 Layout Status

| Block | Status |
|---|---|
| M1/M2 differential pair (ABBA common-centroid) | ✅ Placed |
| M3/M4 PMOS active load | ✅ Placed |
| M5 tail current source | ✅ Placed |
| M6 second-stage amplifier | ✅ Placed |
| M7 second-stage load | ✅ Placed |
| M8 bias reference | ✅ Placed |
| Cc (nmoscap1v) routing | 🔄 In progress |
| Rz routing | 🔄 In progress |
| DRC clean (PVS pvlDRC.rul) | ⏳ Pending |
| LVS clean (PVS pvlLVS.rul) | ⏳ Pending |
| PEX (QRC typical corner) | ⏳ Pending |
| Post-PEX AC comparison | ⏳ Pending |

### 11.2 ABBA Common-Centroid for M1/M2

ABBA common-centroid placement is mandatory for the differential pair. Without it, systematic offset from process gradients cannot be cancelled.

**The problem:** Fabrication conditions vary slowly across the wafer (oxide thickness, implant dose, temperature). If M1 and M2 are placed side by side, each samples a different point on the gradient and ends up with a different Vth — a **systematic** offset that is the same direction on every chip.

**ABBA solution:** Split each transistor into two half-width fingers and interleave:

```
Position:   1      2      3      4
Device:     M1a    M2a    M2b    M1b
            (A)    (B)    (B)    (A)

M1 samples positions 1 and 4:  average = (low + high)/2  = mid
M2 samples positions 2 and 3:  average = (mid + mid)/2   = mid
```

Both transistors see the same gradient average → systematic offset cancels to first order in any direction. Dummy fingers on both outer ends (gate to VSS, source/drain to supply) ensure all active fingers have identical neighbours, eliminating edge effects.

| Mismatch Type | Cause | Fixed by ABBA? | Fixed by Larger W×L? |
|---|---|---|---|
| Systematic offset | Process gradients | ✅ Yes — first-order cancellation | ❌ No |
| Random offset | Atomic-level statistical variation (Pelgrom) | ❌ No | ✅ Yes — σ ∝ 1/√(WL) |

### 11.3 Cc Routing — Most Layout-Sensitive Component

Parasitic routing resistance on Cc directly shifts the nulling zero frequency post-PEX. Every ohm in series with Cc modifies the effective Rz:

- Place Cc physically between NET_B and VOUT to minimise wire length
- Route in Metal 3 or Metal 4 (lower sheet resistance than M1/M2)
- Avoid routing over other signal wires — use a dedicated metal route
- Every 1 µm of M2 routing ≈ 0.05–0.1 Ω additional Rz

### 11.4 Guard Rings

Two separate guard rings required:

**NMOS guard ring:** p+ substrate contact ring around all NMOS (M1, M2, M5, M7, M8) → connects to VSS. Provides low-resistance path for substrate currents; prevents coupling between NMOS devices.

**PMOS guard ring:** n-well contact ring around all PMOS (M3, M4, M6) → connects to VDD. Prevents floating n-well; reduces noise coupling between PMOS and NMOS groups.

NMOS and PMOS guard rings must be physically separate — they must not share contacts.

> Layout screenshot to be added after DRC/LVS signoff.

---

## 12. Results Summary

| Simulation | Parameter | Measured | Target | Status |
|---|---|---|---|---|
| DC | All signal-path devices in saturation | Yes (M5 triode — accepted) | Yes | ✅ |
| DC | VOUT at mid-rail | 0.600 V | 0.600 V | ✅ |
| DC | M1/M2 current match | 38.1 vs 37.98 µA | Matched | ✅ |
| DC | M6/M7 current match | 1.254 mA both | Matched | ✅ |
| AC | DC open-loop gain | 75.6 dB | > 60 dB | ✅ |
| AC | GBW | 57.5 MHz | > 100 MHz | ⚠️ |
| AC | Phase margin (TT/27°C) | 60.9° | > 60° | ✅ |
| Transient | SR rising | 64.5 V/µs | > 20 V/µs | ✅ |
| Transient | SR falling | 55 V/µs | > 20 V/µs | ✅ |
| Transient | Settling time rising (0.1%) | 18.6 ns | < 100 ns | ✅ |
| Transient | Settling time falling (0.1%) | 223 ns | < 100 ns | ❌ |
| Noise | Flicker corner | 1.4 MHz | — | — |
| Noise | Thermal noise floor | 9.5 nV/√Hz | — | — |
| Noise | Integrated RMS | ~107 µV | — | — |
| CMRR | CMRR at 1 kHz | 76.4 dB | > 60 dB | ✅ |
| PSRR | PSRR at 1 kHz | 164.4 dB | > 40 dB | ✅ |
| Corner | PM — TT / all temps | 60.9° – 61.9° | > 60° | ✅ |
| Corner | PM — SS / all temps | 62.3° – 63.7° | > 60° | ✅ |
| Corner | PM — FF / −40°C | 61.2° | > 60° | ✅ |
| Corner | PM — FF / 27°C | 56.9° | > 60° | ❌ |
| Corner | PM — FF / 125°C | 55.7° | > 60° | ❌ |
| Offset | 3σ input offset (Pelgrom) | ~17.4 mV | < 5 mV | ❌ |
| Layout | All devices placed | Yes | — | ✅ |
| DRC / LVS / PEX | — | ⏳ Pending | — | — |

---

## 13. Design Limitations & Engineering Discussion

### GBW (57.5 MHz vs 100 MHz target)
A fundamental constraint of 1.2V supply + 10pF load in 45nm. The three compounding limits (gm1 headroom, Miller loading, p2 ceiling) were all explored — each fix to one spec degrades another. The 57.5 MHz / 60.9° result is the best achievable tradeoff in this design space.

### Falling settling time (223 ns vs 100 ns target)
Caused by the pole-zero doublet from imperfect Rz-Cc cancellation — a known artefact of Miller compensation with a fixed resistor. It scales with GBW: higher GBW would reduce the doublet time constant. Addressable by trimming Rz to exactly 1/gm6 or using an active replica cancellation circuit.

### FF corner PM failure
Systematic, not random — GBW scales faster than p2 in the FF corner. Fix: increase Cc from 1.35 pF to ~1.55 pF, accepting ~12% lower GBW at TT.

### Monte Carlo not run
32-bit Spectre 12.1 environment limitation. Pelgrom's Law gives 17.4 mV 3σ estimate. To be verified with 64-bit Monte Carlo in a full PDK environment.

### Input offset (17.4 mV vs 5 mV target)
M1/M2 at W=4µm is too small for good matching at 45nm. Meeting 5 mV requires W≈100µm which creates a subthreshold headroom conflict at 1.2V. Resolution: chopper stabilisation or relaxed offset spec.

---

## 14. Environment & 32-bit Workarounds

Running Cadence IC615 on CentOS 6 32-bit required several non-obvious fixes:

| Issue | Fix |
|---|---|
| Full GPDK045 models use Verilog-A subcircuits (g45n1svt/g45p1svt) → segfault on 32-bit Spectre | Redirect all model sections in `gpdk045.scs` to `0.1_models/` PTM BSIM4 files (no Verilog-A) |
| Model name mismatch: schematics use `g45n1svt`, `0.1_models` defines `gpdk045_nmos1v` | Insert BSIM4 parameter block copies with g45n1svt/g45p1svt aliases into NN, SS, FF sections of `0.1_models/gpdk045_mos.scs` |
| Monte Carlo — full models required for statistics block | Not achievable; estimated analytically via Pelgrom's Law |
| ADE XL temperature sweep fails silently | Variable must be named exactly `temperature` (lowercase) — `temp` or `Temperature` cause silent errors |
| AHDL compiler memory issues | `CDS_CMI_COMPLEVEL=0` added to `~/.bashrc` |
| SFE-874 from duplicate model file entries | Remove all extra entries from Setup → Model Libraries; keep only one correct path |

---

## Key Equations Quick Reference

| Parameter | Formula | This Design |
|---|---|---|
| GBW | `gm1 / (2π·Cc)` | 601µA / (2π × 1.35pF) = 70.8 MHz (theoretical) |
| p2 | `gm6 / (2π·CL)` | 12.07mA / (2π × 10pF) = 192 MHz |
| PM ≥ 60° | `p2 > 2.2 × GBW` | 192 > 126.5 ✅ |
| Ideal Rz | `1/gm6` | 1/12.07mA = 83 Ω → used 100 Ω |
| Flicker corner | `(Vnoise_1Hz / Vthermal)² × 1Hz` | (11391/9.5)² = 1.44 MHz |
| Pelgrom sigma | `√2 × AVT / √(W·L)` | √2 × 3mV / √(4u × 0.18u) = 4.99 mV per pair |

---

## Supporting Documents

| File | Contents |
|---|---|
| [`OTA_Simulation_Report_AC_DC.docx`](OTA_Simulation_Report_AC_DC.docx) | Formal simulation report — DC operating point, AC/STB results, debug history |
| [`OTA_Simulation_Study_Guide_v2.docx`](OTA_Simulation_Study_Guide_v2.docx) | Complete study guide — all simulations, equations, interview prep, environment notes |
