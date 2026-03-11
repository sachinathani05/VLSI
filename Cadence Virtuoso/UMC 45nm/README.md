# CMOS Standard Cell Design — UMC 65nm Technology
### EEE8127 Digital IC Design | Newcastle University | School of Engineering

> **Complete CMOS IC design and characterisation flow** implemented in UMC 65nm technology using Cadence Virtuoso, Mentor Calibre, and Spectre simulator. Covers standard cell design from schematic to verified layout, followed by three experimental studies: fanout loading, wire delay, and energy-performance tradeoff under VDD scaling.

---

## 🔧 Tools & Technology

| Tool | Purpose |
|---|---|
| Cadence Virtuoso Schematic Editor | Schematic capture and symbol generation |
| Cadence Virtuoso LayoutXL | Physical layout design |
| Cadence ADE-L + Spectre | Transient simulation and waveform analysis |
| Mentor Calibre DRC | Design Rule Check |
| Mentor Calibre LVS | Layout vs. Schematic verification |
| Mentor Calibre PEX (xRC) | Full RC parasitic extraction |
| UMC 65nm Low-Leakage PDK | Process design kit |

**Nominal VDD:** 1.0V &nbsp;|&nbsp; **Min functional VDD:** ~0.4V &nbsp;|&nbsp; **Temperature:** 27°C (TT corner)

---

## 📁 Repository Structure

```
VLSI-65nm-Standard-Cell-Design/
│
├── Part_A/                          ← Standard Cell Design & Verification
│   ├── Inverter/
│   │   ├── schematic/               inv1_schematic.png, inv1_symbol.png
│   │   ├── layout/                  inv1_layout.png
│   │   ├── verification/            drc_result.png, lvs_result.png, pex_view.png
│   │   └── simulation/              waveforms_pre.png, waveforms_post.png, iinteg.png
│   ├── Tristate_Inverter/
│   │   ├── schematic/
│   │   ├── layout/
│   │   ├── verification/
│   │   └── simulation/
│   └── D_Flip_Flop/
│       ├── schematic/
│       ├── layout/
│       ├── verification/
│       └── simulation/
│
├── Part_B/                          ← Experimental Characterisation
│   ├── Experiment_1_Fanout/
│   │   ├── testbenches/             fo0_tb.png, fo1_tb.png, fo2_tb.png, fo4_tb.png
│   │   ├── simulation/              fanout_waveforms.png
│   │   ├── cin_sweep/               cin_sweep_schematic.png, cin_sweep_extracted.png
│   │   └── plots/                   delay_vs_fanout.png, cin_determination.png
│   ├── Experiment_2_Wire_Delay/
│   │   ├── layouts/                 short_wire_layout.png, long_wire_layout.png
│   │   ├── simulation/              short_wire_waveforms.png, long_wire_waveforms.png
│   │   ├── cload_sweep/             cload_sweep_table.png
│   │   └── plots/                   wire_delay_comparison.png
│   └── Experiment_3_Energy_VDD/
│       ├── testbench/               inv_chain_schematic.png, inv_chain_tb.png
│       ├── simulation/              delay_waveforms_vdd.png, energy_iinteg.png
│       └── plots/                   delay_vs_vdd_merged.png, energy_vs_vdd.png
│
├── Report/
│   └── Full_Report_EEE8127.docx
│
└── README.md
```

---

# PART A — Standard Cell Design and Verification

> Three standard cells were designed, laid out, and verified in UMC 65nm: a minimum-size inverter, a tri-state inverter, and a master-slave D flip-flop. Each cell follows the UMC 65nm standard cell template: 3.0µm fixed height, 0.6µm-wide VDD/GND power rails in M1, n-well boundary at y=1.5µm, and continuous substrate/n-well at cell boundaries for seamless abutment.

---

## 1. Inverter (`inv1`)

### 1.1 Background and Transistor Sizing

The inverter was sized using **Logical Effort (LE)** theory, which targets a pMOS:nMOS width ratio of approximately 2:1 to equalise pull-up and pull-down drive strength based on mobility ratios. However, at 65nm, velocity saturation reduces the effective mobility gap between carriers — making a ratio closer to **1.6:1 more appropriate**.

A critical constraint emerged from UMC 65nm design rules: the minimum diffusion width for **dual contacts** (required for manufacturing yield) is 350nm for NMOS. The initial 280nm nMOS width accommodates only a single contact — a DRC violation. Increasing to 350nm resolves this, yielding a final ratio of 560:350 = **1.6:1**, which is both DRC-compliant and physically correct for 65nm.

| Transistor | Width | Reasoning |
|---|---|---|
| pMOS | 560 nm | Logical Effort sizing for mobility balance |
| nMOS | 350 nm | Minimum width to fit dual contacts (DRC rule) |
| W ratio | 1.6:1 | Appropriate for velocity-saturated 65nm devices |
| Gate length | 60 nm | Minimum gate length for UMC 65nm |

> **Key insight:** This demonstrates how theoretical specifications (LE gives 2:1) must reconcile with manufacturing constraints — a fundamental skill in real IC design flows.

### 1.2 Schematic and Symbol

- Complementary pMOS (pull-up) and nMOS (pull-down) share a common gate input `in` and common drain output `out`
- Source of pMOS connected to global power net `vdd!`; source of nMOS to `gnd!`
- Symbol generated from schematic and refined to standard inverter triangle-with-circle notation for use in hierarchical designs (tri-state inverter and DFF)

📸 **Upload here:** `Part_A/Inverter/schematic/inv1_schematic.png`, `inv1_symbol.png`

### 1.3 Layout

The layout follows the UMC 65nm standard cell template:

- **3.0µm fixed height** — VDD rail at y=3.0µm, GND at y=0.0µm (each 0.6µm wide M1)
- **N-well boundary at y=1.5µm** — splits cell into PMOS region (upper) and NMOS region (lower)
- **PPLUS/NPLUS implant layers** — define diffusion polarity and prevent latch-up
- **Dual contacts per source/drain diffusion** — satisfies UMC 65nm minimum contact yield rules
- **Continuous substrate and n-well at cell boundaries** — enables seamless abutment with neighbouring cells; no redundant boundary shapes needed

📸 **Upload here:** `Part_A/Inverter/layout/inv1_layout.png`

### 1.4 Verification: DRC / LVS / PEX

**DRC (Calibre):**
All critical design rules passed — width, spacing, enclosure, and contact rules satisfied. Minor metal density violations were flagged but are within acceptable process limits and can be waived at tape-out.

**LVS (Calibre):**
Layout vs. Schematic confirmed clean match:
- 2 transistors (1 pMOS, 1 nMOS) matched
- Correct net connectivity verified (gate, drain, source for each device)
- Pin assignments (`in`, `out`, `vdd!`, `gnd!`) confirmed correct

**PEX (Calibre xRC):**
Parasitic extraction completed successfully, generating `av_extracted` view with full RC network. Captured parasitics include gate-drain overlap capacitance (Cgd), diffusion/junction capacitance at source/drain nodes, and M1 routing resistance and fringing capacitance — all invisible at schematic level.

📸 **Upload here:** `Part_A/Inverter/verification/drc_result.png`, `lvs_result.png`, `pex_view.png`

### 1.5 Simulation Results

**Conditions:** VDD = 1.0V, T = 27°C, input vpulse 0→1V with 10ps rise/fall. Delays at VDD/2 crossing. Energy = VDD × ∫|I_vdd(t)|dt over one switching period.

| Metric | Pre-Layout (Schematic) | Post-Layout (Extracted) | Change |
|---|---|---|---|
| tpHL (fall delay) | 32.05 ps | 35.99 ps | +12.3% |
| tpLH (rise delay) | 39.45 ps | 45.93 ps | +16.4% |
| tp Average | 35.75 ps | 40.96 ps | +14.6% |
| Energy / cycle | 1.748 fJ | 2.493 fJ | **+42.6%** |

**Why post-layout is slower and less efficient:** Post-layout parasitics add routing capacitance and resistance to the output node RC time constant. Each switching event must charge/discharge additional capacitance beyond what the schematic predicts. The energy increase (+42.6%) is disproportionately larger than the delay increase (+14.6%) because energy scales as CV², making it more sensitive to additional parasitic capacitance.

📸 **Upload here:** `Part_A/Inverter/simulation/inv1_waveforms_pre.png`, `inv1_waveforms_post.png`, `inv1_iinteg.png`

---

## 2. Tri-State Inverter (`Tristate_inv1`)

### 2.1 Background

A tri-state inverter adds an enable control to the standard inverter, creating three output states: **drive high**, **drive low**, or **Hi-Z (high-impedance)**. When disabled (`e=0`), the output floats — essential for shared bus architectures, multiplexers, and critically, the feedback paths inside the D flip-flop in Section 3.

The enable function is implemented by inserting a series NMOS (controlled by `e`) in the pull-down stack and a series PMOS (controlled by `ne` = NOT e) in the pull-up stack.

### 2.2 Transistor Sizing

The series enable transistors introduce additional resistance, degrading drive strength. To compensate, **internal inverting transistors are doubled in width (2×)**:

| Transistor | Width | Reasoning |
|---|---|---|
| Internal pMOS | 1120 nm | 2× inverter pMOS — compensates series enable resistance |
| Internal nMOS | 700 nm | 2× inverter nMOS — compensates series enable resistance |
| Enable pMOS (gate = `ne`) | 560 nm | Standard size — pass-gate function only |
| Enable nMOS (gate = `e`) | 350 nm | Standard size — pass-gate function only |

**Truth table:**

| Enable (e) | Input (x) | Output (y) |
|---|---|---|
| 1 | 0 | 1 — pull-up stack active |
| 1 | 1 | 0 — pull-down stack active |
| 0 | X | **Hi-Z** — both stacks open |

### 2.3 Layout

- 3.0µm height maintained for row compatibility — identical to inverter
- **Cell width ~1.8× the inverter** — due to doubled transistor widths and additional enable transistors
- **3–4 contact columns per diffusion** required for wider DIFF regions (inverter uses 2 columns)
- `e` and `ne` signals routed in M1 with adequate DRC spacing between the NMOS and PMOS series stacks
- **Shared diffusion at series connection nodes** reduces internal parasitic capacitance between stacked transistors

📸 **Upload here:** `Part_A/Tristate_Inverter/layout/tristate_layout.png`

### 2.4 Simulation Results

| Metric | Pre-Layout | Post-Layout | Change |
|---|---|---|---|
| tpHL (enabled) | 46.74 ps | 50.65 ps | +8.4% |
| tpLH (enabled) | 51.87 ps | 58.72 ps | +13.2% |
| Energy / cycle | 4.326 fJ | 5.078 fJ | **+17.4%** |

**Current spike characteristics:** The tri-state spike is broader than the inverter's due to series resistance and the larger internal node capacitance (longer RC time constant). The higher peak charge reflects doubled gate capacitances and larger short-circuit current through the wider transistors. A slight inflection is sometimes visible in the spike, indicating two-stage switching — enable transistor activates first, then the internal inverter drives the output. Post-layout spike is flatter and more spread, directly visualising the RC slowdown from extraction.

📸 **Upload here:** `Part_A/Tristate_Inverter/simulation/tristate_waveforms.png`, `tristate_iinteg.png`

---

## 3. D Flip-Flop (`d_flipflop1`)

### 3.1 Master-Slave Architecture

The DFF is implemented as a **master-slave latch pair**, each latch built from one tri-state inverter (transparent when enabled, Hi-Z when disabled) and one feedback inverter (holds state when the tri-state is in Hi-Z). No new transistors are drawn — the design reuses the pre-verified `inv1` and `Tristate_inv1` symbols. This demonstrates hierarchical design reuse: verified sub-cells compose into a more complex verified cell.

```
CLK = 0 (Capture phase):
  D ──► [I10: Master TSinv, e=CLK_bar=1] ──► internal node
        [I14: Master inv] ◄── internal node (feedback, holds when CLK=1)
        [I11: Slave TSinv, e=CLK=0] = Hi-Z
        [I16: Slave inv] holds Q stable

CLK = 1 (Propagate phase):
  [I10: Master TSinv, e=CLK_bar=0] = Hi-Z (master holds via I14)
  internal node ──► [I11: Slave TSinv, e=CLK=1] ──► Q
                    [I16: Slave inv] ◄── Q (feedback)
```

**Linear cell arrangement for layout:**
```
[I10: master TSinv] ── [I14: master feedback inv] ── [I11: slave TSinv] ── [I16: slave feedback inv]
```

### 3.2 Layout by Hierarchical Abutment

All four sub-cells share the same 3.0µm PR boundary height. Abutting them horizontally creates:

- **Merged VDD/GND rails** — continuous M1 power stripes across the full DFF cell width, no gaps
- **Continuous n-well and p-substrate** across all four cells — no redundant boundary shapes, no inter-cell latch-up risk
- **No wasted area** between cells — tighter than placing them with spacing

**Metal routing strategy used:**
- **M1** — local connections within each sub-cell and short inter-cell signals
- **M2** — intermediate routing crossing over M1 congestion between adjacent cells
- **M3** — longer feedback paths spanning multiple cells (e.g., Q feedback to slave input)
- **M1→M2 vias** and **M2→M3 vias** at all layer transition points

**Final dimensions:** 3.0µm height × approximately 4× inverter width

📸 **Upload here:** `Part_A/D_Flip_Flop/layout/dff_layout.png`

### 3.3 Simulation Results

| Metric | Pre-Layout | Post-Layout | Change |
|---|---|---|---|
| Energy / cycle | 89.49 fJ | 174.6 fJ | **+95.1%** |

**Dual-spike structure of DFF current:** The supply current waveform shows two distinct spikes per clock cycle:
- **Primary spike (rising CLK edge):** Master latch opens — D propagates through I10; I14 re-engages feedback in slave; I11 slave opens and Q updates
- **Secondary spike (falling CLK edge):** Master latch closes; I14 holds master node; minor charge redistribution as slave settles

Most DFF energy is **clock-related overhead** consumed every cycle regardless of whether data D actually changes. This directly motivates **clock gating** as the primary power reduction technique in flip-flop-heavy datapaths.

📸 **Upload here:** `Part_A/D_Flip_Flop/simulation/dff_waveforms.png`, `dff_iinteg.png`

---

# PART B — Experimental Characterisation

> All three experiments use the verified `inv1` from Part A as their fundamental building block, enabling direct comparison between idealised schematic-level behaviour and silicon-accurate post-extraction results. Together they quantify three dimensions of the gap between theory and silicon reality in 65nm CMOS.

---

## Experiment 1 — Fanout Analysis

### Theory

The **Logical Effort (LE)** method (Sutherland, Sproull & Harris) predicts propagation delay as:

```
tpd = tp0 × (1 + f)

where:
  tp0 = intrinsic delay (zero-fanout — captures internal parasitics only)
  f   = Cload / Cin   (fanout ratio)
```

This model **implicitly assumes Cpar ≪ Cin** — that internal parasitic capacitance is small compared to the gate input capacitance. This experiment tests whether that assumption holds at 65nm minimum geometry.

### Circuit Setup

Four testbenches, each with an `inv1` driver loaded by 0, 1, 2, or 4 parallel `inv1` inputs:

| Testbench | Load | Purpose |
|---|---|---|
| FO0 | None | Isolates intrinsic delay tp0 — anchors all LE predictions |
| FO1 | 1× inv1 | Unit fanout reference point |
| FO2 | 2× inv1 | Tests linearity of delay-vs-fanout response |
| FO4 | 4× inv1 | Industry-standard FO4 metric — represents realistic clock buffer loads |

**Cin determination:** A separate FO0 testbench with variable capacitor swept from 0.5fF to 5.0fF in 0.5fF steps. The capacitance value that replicates the FO1 delay directly yields Cin — done separately for schematic and extracted views.

**Simulation conditions:** VDD = 1.0V, T = 27°C, 10ps rise/fall vpulse, delays at VDD/2 crossing.

📸 **Upload here:** `Part_B/Experiment_1_Fanout/testbenches/fo0_tb.png`, `fo4_tb.png`, `simulation/fanout_waveforms.png`

### Results

**Measured delays — schematic vs. extracted:**

| Fanout | tp Schematic (ps) | tp Extracted (ps) | Extracted overhead |
|---|---|---|---|
| FO0 | 17.07 | 23.13 | +35% |
| FO1 | 22.50 | 29.25 | +30% |
| FO2 | 26.55 | 35.08 | +32% |
| FO4 | 34.14 | 47.05 | +38% |

**Logical Effort accuracy check:**

| Fanout | LE Prediction Schem (ps) | Simulated Schem (ps) | LE Error |
|---|---|---|---|
| FO0 | 17.07 | 17.07 | 0% (by definition — tp0 anchor) |
| FO1 | 34.14 | 22.50 | **−34%** |
| FO2 | 51.21 | 26.55 | **−48%** |
| FO4 | 85.35 | 34.14 | **−60%** |

> LE overestimates delay by up to **60% at FO4**. This is not a modelling error — it is a direct consequence of 65nm device physics.

**Input capacitance (Cin) extraction:**

| View | Cin fall (fF) | Cin rise (fF) | Cin Average (fF) |
|---|---|---|---|
| Schematic | 0.681 | 0.726 | **0.703** |
| Extracted | 1.044 | 1.111 | **1.078** |
| Parasitic overhead | — | — | **+53%** |

Interpolation method (example — schematic fall):
```
Target tpHL at FO1 = 20.25 ps
Sweep shows: 19.17 ps at 0.5fF, 22.15 ps at 1.0fF
C_in = 0.5 + [(20.25 − 19.17) / (22.15 − 19.17)] × 0.5 = 0.681 fF
```

📸 **Upload here:** `Part_B/Experiment_1_Fanout/cin_sweep/cin_sweep_schematic.png`, `cin_sweep_extracted.png`, `plots/delay_vs_fanout.png`, `plots/cin_determination.png`

### Why LE Fails at 65nm

The corrected delay model for a real 65nm cell is:
```
tpd = 0.69 × Req × (Cpar + f × Cin)
```

Extracting parameters from the measured data:
- Delay slope = **4.43 ps per fanout unit** (schematic)
- **Req = 4.43 / (0.69 × 0.703 fF) = 9.13 kΩ**
- **Cpar = tp0 / (0.69 × Req) = 17.07 / (0.69 × 9130) = 2.71 fF**
- **Cpar / Cin ≈ 3.9×** — internal parasitic capacitance is nearly **4× larger** than input capacitance

The LE formula's implicit assumption (Cpar ≪ Cin) is violated by a factor of ~4 at 65nm minimum geometry. At 65nm, diffusion and overlap parasitics dominate over gate oxide capacitance. **LE should be used only for architectural planning — never for timing sign-off at advanced nodes.**

---

## Experiment 2 — Wire Delay Characterisation

### Theory

As CMOS scaling reduces gate delays into the single-digit picosecond range, interconnect delay becomes the dominant bottleneck. The **Elmore RC delay model** for a distributed wire gives:

```
tpd(wire) = 0.38 × r₁ × c₁ × L²

where:
  r₁ = resistance per unit length (Ω/µm)
  c₁ = capacitance per unit length (fF/µm)
  L  = wire length (µm)
```

The critical feature is the **L² quadratic dependence**: doubling wire length quadruples delay — fundamentally different from gate delay, which scales approximately linearly with technology generation. This experiment finds the crossover length where wire delay equals gate delay.

### Circuit and Layout

Two physical layouts of the same schematic — two cascaded `inv1` instances connected by inter-stage M1 wire `net5`:

**Short wire (~1µm):**
- Both inverters placed adjacently with a direct minimum-length M1 connection
- Compact layout — wire parasitic contribution is negligible, close to schematic baseline
- Represents typical intra-cell or adjacent-cell routing

**Long serpentine wire (~100µm):**
- Inverters at opposite ends of an elongated cell
- `net5` routed as a **serpentine meander** in M1 to achieve ~100µm total path length within compact area
- Represents global routing across a design block in an SoC

The schematic is **identical for both layouts** — all delay difference is purely from physical wire parasitics captured by Calibre PEX.

📸 **Upload here:** `Part_B/Experiment_2_Wire_Delay/layouts/short_wire_layout.png`, `long_wire_layout.png`

### Simulation Results

Calibre PEX applied to both layouts. VDD = 1.0V, T = 27°C.

| Configuration | View | tpHL (ps) | tpLH (ps) | tp Avg (ps) |
|---|---|---|---|---|
| Short wire (1µm) | Schematic | 32.36 | 35.81 | 34.09 |
| Short wire (1µm) | Extracted | 42.38 | 47.08 | 44.73 |
| Long wire (100µm) | Schematic | 32.36 | 35.81 | 34.09 |
| Long wire (100µm) | Extracted | 98.70 | 114.0 | 106.35 |
| **Wire-added delay (Long − Short)** | — | 56.32 | 66.92 | **61.62** |

📸 **Upload here:** `Part_B/Experiment_2_Wire_Delay/simulation/short_wire_waveforms.png`, `long_wire_waveforms.png`

### Equivalent Capacitance Calculation

A parametric Cload sweep (1fF to 15fF, step 1fF) on the schematic testbench identifies the lumped capacitance that replicates each extracted delay. Interpolation:

```
C = C_low + [(target_delay − delay_low) / (delay_high − delay_low)] × step
```

**Short wire (1µm):**
```
Rise: tpLH = 47.08ps → between 2fF (45.74ps) and 3fF (51.92ps)
  C = 2 + [(47.08 − 45.74) / (51.92 − 45.74)] × 1 = 2.22 fF
Fall: tpHL = 42.38ps → between 1fF (41.74ps) and 2fF (46.73ps)
  C = 1 + [(42.38 − 41.74) / (46.73 − 41.74)] × 1 = 1.13 fF
→ C_wire(short) average = 1.68 fF
```

**Long wire (100µm):**
```
Rise: tpLH = 114.0ps → between 12fF (113.5ps) and 13fF (119.8ps)
  C = 12 + [(114.0 − 113.5) / (119.8 − 113.5)] × 1 = 12.08 fF
Fall: tpHL = 98.70ps → between 13fF (96.11ps) and 14fF (100.5ps)
  C = 13 + [(98.70 − 96.11) / (100.5 − 96.11)] × 1 = 13.59 fF
→ C_wire(long) average = 12.84 fF
```

**Summary:**

| Configuration | tp Avg (ps) | Total C_wire (fF) | Wire-only C (fF) |
|---|---|---|---|
| Short wire (1µm) | 44.73 | 1.68 | ~0 (cell layout parasitics) |
| Long wire (100µm) | 106.35 | 12.84 | — |
| **Wire-only (99µm difference)** | **+61.62** | **11.16** | **0.113 fF/µm** |

> **Physical validation:** M1 capacitance density at 65nm is typically 0.1–0.2 fF/µm for minimum-width routing. The measured 0.113 fF/µm is physically consistent — confirming Calibre PEX extraction accuracy.

📸 **Upload here:** `Part_B/Experiment_2_Wire_Delay/cload_sweep/cload_sweep_table.png`, `plots/wire_delay_comparison.png`

### Critical Wire Length

```
Baseline gate-only delay (schematic):  34.09 ps
Wire delay rate:                        61.62 ps / 99µm = 0.616 ps/µm
Length to equal one full gate delay:    L = 34.09 / 0.616 ≈ 55 µm
```

> **Any M1 wire longer than ~55µm will add more delay than the entire two-inverter gate chain.** In SoC blocks with dimensions of 0.5–5mm, this threshold is routinely exceeded — making buffer insertion a mandatory design step, not optional.

**Why the L² dependence is the critical issue:**
- Halving wire length reduces wire delay by **4×** (not 2×)
- This is why modern EDA tools aggressively insert repeater buffers every 200–500µm on timing-critical global routes
- Higher metal layers (M5–M8) with thicker metal reduce r₁ by 2–3× for the same routing length — critical path routing should avoid congested lower metal layers

---

## Experiment 3 — Energy-Performance Tradeoff under VDD Scaling

### Theory

Dynamic power in CMOS scales as:
```
P = α × C × VDD² × f
```
Reducing VDD quadratically reduces power but degrades speed via the **alpha-power law**:
```
tpd ∝ 1 / (VDD − VTH)^α,   α ≈ 1.3–1.5 for 65nm short-channel devices
```
These two effects create a **U-shaped energy-VDD curve** with a minimum — the **Minimum Energy Point (MEP)**. This experiment maps the full delay and energy landscape from minimum functional VDD (~0.4V) to 2× nominal (2.0V).

### Circuit: 48-Stage Inverter Chain

A chain of **48 cascaded minimum-size `inv1` inverters** sweeps VDD from 0.2V to 2.0V:
- Even count (48) → non-inverted output, straightforward delay measurement
- 48 stages amplify small per-gate differences, improving measurement accuracy at near-threshold VDD
- **Energy measured as:** `E = VDD × ∫|I_vdd(t)| dt` with integration window = tp at each VDD (critical: a fixed window would overestimate energy at low VDD where delays are much longer)

📸 **Upload here:** `Part_B/Experiment_3_Energy_VDD/testbench/inv_chain_schematic.png`, `inv_chain_tb.png`

### Delay vs. VDD Results

| VDD (V) | tpLH (ps) | tpHL (ps) | tp Avg (ps) | Per-stage (ps) | Normalised |
|---|---|---|---|---|---|
| 0.2 | Fails | Fails | **Circuit fails** | — | — |
| 0.4 | ~1200 | ~1200 | ~1200 | ~25.0 | ~1.96× |
| 0.6 | 5292 | 5425 | 5359 | 111.6 | 8.74× |
| 0.8 | 1235 | 1255 | 1245 | 25.9 | 2.03× |
| **1.0** | **612** | **614** | **613** | **12.8** | **1.00× (nominal)** |
| 1.2 | 415 | 408 | 411 | 8.6 | 0.67× |
| 1.4 | 326 | 310 | 318 | 6.6 | 0.52× |
| 1.6 | 280 | 253 | 266 | 5.5 | 0.43× |
| 1.8 | 255 | 216 | 235 | 4.9 | 0.38× |
| 2.0 | 255 | 187 | 221 | 4.6 | 0.36× |

**Four operating regions visible in the delay graph:**

| Region | VDD Range | Key Characteristic |
|---|---|---|
| 🔴 Non-functional | < 0.4V | No rail-to-rail switching — subthreshold leakage cannot drive logic transitions |
| 🟡 Near-threshold | 0.4–1.0V | Extreme sensitivity — 8.7× delay improvement from 0.6V to 1.0V. Small supply droop causes disproportionate timing violations |
| 🟢 Normal operation | 1.0–1.4V | Good delay/energy balance — nominal design region |
| 🔵 Saturation | > 1.4V | Velocity saturation limits: <15% improvement per 0.2V step. Increasing VDD yields diminishing returns while raising reliability stress |

**Rise/fall asymmetry:** Rise delay (tpLH) consistently exceeds fall delay (tpHL). Despite the 1.6× width compensation, PMOS hole mobility µp ≈ 0.6µn — and velocity saturation disproportionately limits PMOS at short channel lengths. The asymmetry grows at higher VDD as NMOS benefits more from increased overdrive.

📸 **Upload here:** `Part_B/Experiment_3_Energy_VDD/plots/delay_vs_vdd_merged.png`

### Energy vs. VDD Results

| VDD (V) | tp Avg (ps) | Energy / chain (fJ) | Energy / stage (aJ) | Ceff = 2E/VDD² (fF) |
|---|---|---|---|---|
| 0.6 | 5359 | 0.948 | 19.8 | 5.27 |
| **0.8** | **1245** | **0.719 ← MEP** | **15.0** | **2.25** |
| 1.0 | 613 | 0.965 | 20.1 | 1.93 |
| 1.2 | 411 | 1.297 | 27.0 | 1.80 |
| 1.4 | 318 | 1.588 | 33.1 | 1.62 |
| 1.6 | 266 | 1.920 | 40.0 | 1.50 |
| 1.8 | 235 | 2.215 | 46.1 | 1.37 |
| 2.0 | 221 | 2.366 | 49.3 | 1.18 |

### Minimum Energy Point (MEP) Analysis

The U-shaped curve arises from two competing energy components:

**Dynamic switching energy** `E_dyn ∝ C × VDD²` — dominates at high VDD, increasing quadratically. At 2.0V vs. 0.8V, this term is (2.0/0.8)² = **6.25× higher**.

**Leakage and short-circuit energy** `E_leak ∝ I_leak × tp(VDD)` — dominates at low VDD because both subthreshold leakage grows exponentially below VTH and delays become very large (tp at 0.6V is ~5.4ns vs. 613ps at 1.0V). Short-circuit energy peaks near VTH as both NMOS and PMOS simultaneously conduct for a larger fraction of each transition.

**The MEP at VDD = 0.8V offers:**
- **25.5% energy saving** vs. nominal 1.0V operation
- At the cost of **2× delay penalty** (1245ps vs. 613ps)
- Optimal tradeoff for: IoT sensors, wearables, sleep-mode controllers, RFID

**Ceff = 2E/VDD² trend:** Decreases from 5.27 fF (0.6V) to 1.18 fF (2.0V). At low VDD, both NMOS and PMOS remain partially ON longer during transitions, adding short-circuit energy beyond the ideal C×VDD² term. Fast transitions at high VDD minimise this overlap. This means that `C×VDD²` alone underestimates total switching energy at low VDD.

📸 **Upload here:** `Part_B/Experiment_3_Energy_VDD/plots/energy_vs_vdd.png`

### Energy-Delay Product (EDP)

EDP = E × tp is a technology figure of merit that quantifies the fundamental energy-performance tradeoff independent of the chosen operating point:

| VDD (V) | tp Avg (ps) | Energy (fJ) | EDP (fJ·ps) | Normalised EDP |
|---|---|---|---|---|
| 0.8 | 1245 | 0.719 | 895.6 | 1.00 |
| 1.0 | 613 | 0.965 | 591.7 | 0.66 |
| 1.2 | 411 | 1.297 | 533.1 | 0.60 |
| **1.4** | **318** | **1.588** | **504.9** | **0.56 ← minimum EDP** |
| 1.6 | 266 | 1.920 | 510.7 | 0.57 |
| 2.0 | 221 | 2.366 | 523.0 | 0.58 |

> **The minimum EDP occurs at 1.2–1.4V — above the nominal 1.0V.** The UMC 65nm process nominal voltage is a conservative reliability-driven choice (gate oxide lifetime, hot-carrier injection) rather than a physics-optimal EDP point. This is consistent with the IRDS finding that supply voltage scaling has slowed at advanced nodes due to reliability, not device performance.

---

## 📊 Generated Plots

| File | Description |
|---|---|
| `delay_vs_vdd_merged.png` | Rise, fall and average delay vs. VDD — all four operating regions colour-coded and annotated |
| `energy_vs_vdd.png` | U-shaped energy curve + delay overlay on dual y-axis — MEP at 0.8V annotated |
| `delay_vs_fanout.png` | Measured delays vs. LE predictions for FO0–FO4 — schematic and extracted series |
| `cin_determination.png` | Delay vs. swept Cload — FO1 target dashed lines showing Cin intersection points |

---

## 🔑 Key Design Guidelines

These are directly actionable conclusions from the experimental data — not textbook rules:

1. **Always use post-layout Cin for timing closure.** Schematic Cin underestimates by 53% at 65nm. Timing budgets built on schematic capacitance will not close after layout.

2. **Buffer any M1 wire longer than ~55µm on timing-critical paths.** Beyond this, wire delay exceeds the full two-inverter gate delay (34ps). In SoC blocks this threshold is routinely exceeded on global signals.

3. **Target VDD = 0.8V for minimum energy applications.** 25.5% energy saving vs. nominal, at 2× delay cost. Optimal for IoT, wearables, always-on logic.

4. **Target VDD = 1.2–1.4V for minimum EDP.** The nominal 1.0V is not physics-optimal from an energy-delay perspective — it is a reliability-driven conservative choice.

5. **Do not use Logical Effort for 65nm timing sign-off.** LE overestimates delay by 34–60% at minimum geometry due to Cpar/Cin ≈ 4:1. Use LE for architectural planning, always validate with extracted simulation.

6. **The near-threshold region (0.4–1.0V) is extremely sensitive.** 8.7× delay improvement across this range. Supply droop from switching noise in this region creates disproportionate timing violations — worst-case IR drop analysis is mandatory.

---

## 📚 Concepts Demonstrated

- CMOS transistor sizing and Logical Effort (LE) theory
- Standard cell methodology: fixed height, abutment, power rail continuity
- Full DRC / LVS / PEX verification flow using Calibre
- Pre-layout vs. post-layout simulation — parasitic impact quantification
- Fanout loading analysis and Cin extraction by parametric capacitor sweep
- Elmore RC wire delay model and quadratic length dependence (L²)
- Dynamic power, leakage, and short-circuit energy decomposition
- Minimum Energy Point (MEP) identification and physical explanation
- Energy-Delay Product (EDP) as a process-level figure of merit
- Alpha-power law for delay under VDD scaling
- Near-threshold computing characteristics and design challenges
- Hierarchical design methodology: DFF built entirely from pre-verified sub-cells

---

## 📖 References

- Sutherland, Sproull & Harris — *Logical Effort: Designing Fast CMOS Circuits*, Morgan Kaufmann, 1999
- Elmore, W.C. — *The Transient Response of Damped Linear Networks*, J. Appl. Phys., 1948
- Sakurai & Newton — *Alpha-Power Law MOSFET Model*, IEEE JSSC, 1990
- IRDS — *International Roadmap for Devices and Systems, 2022 Edition*
- UMC 65nm Low-Leakage Process Design Kit (umc65ll)
- Cadence Virtuoso ADE-L User Guide
- Mentor Calibre DRC / LVS / xRC User Guide

---

*Newcastle University — School of Engineering — EEE8127 Digital IC Design — 2025/2026*
