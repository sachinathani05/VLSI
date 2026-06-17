# UART RTL-to-GDSII — SKY130 130nm

**Tool:** OpenLane 2.3.10 (Classic Flow) · Yosys 0.46 · OpenROAD (Floorplan/Placement/CTS/Routing) · OpenSTA · Magic (DRC/GDS/SPICE) · Netgen (LVS) · KLayout (DRC/GDS/Viewer)
**PDK:** SkyWater SKY130A · `sky130_fd_sc_hd` High-Density library · VDD = 1.8V · 130nm
**OS:** WSL2 Ubuntu 22.04 (Windows 10) · Docker Desktop · OSS CAD Suite

---

## Table of Contents

1. [RTL Design](#1-rtl-design)
2. [Timing Constraints (SDC)](#2-timing-constraints-sdc)
3. [Synthesis](#3-synthesis)
4. [Floorplan](#4-floorplan)
5. [Placement](#5-placement)
6. [Clock Tree Synthesis](#6-clock-tree-synthesis)
7. [Routing — Global & Detailed](#7-routing--global--detailed)
8. [Static Timing Analysis — Sign-off](#8-static-timing-analysis--sign-off)
9. [DRC & LVS Sign-off](#9-drc--lvs-sign-off)
10. [GDSII Export](#10-gdsii-export)
11. [Results Summary](#11-results-summary)
12. [Engineering Discussion & Design Decisions](#12-engineering-discussion--design-decisions)
13. [Environment Setup & Debugging Log](#13-environment-setup--debugging-log)
14. [Key Equations Quick Reference](#14-key-equations-quick-reference)

---

## 1. RTL Design

A UART (Universal Asynchronous Receiver-Transmitter) is a serial communication peripheral — no shared clock wire between devices, just an agreed-upon baud rate. A frame consists of an idle line (HIGH), one start bit (LOW), 8 data bits (LSB first), and one stop bit (HIGH).

```
IDLE  START  D0  D1  D2  D3  D4  D5  D6  D7  STOP  IDLE
 1      0    b0  b1  b2  b3  b4  b5  b6  b7    1     1
```

### 1.1 Module Hierarchy

| Module | FSM States | Key Mechanism |
|---|---|---|
| `uart_tx.v` | IDLE → START → DATA → STOP | `tx_data_latch` snapshots `tx_data` on `tx_start` pulse, preventing mid-transmission corruption if the input changes |
| `uart_rx.v` | IDLE → START → DATA → STOP | Mid-bit sampling: counts to `CLKS_PER_BIT/2` in START to confirm a real start bit (glitch rejection), then samples every subsequent bit at its midpoint for maximum signal stability |
| `uart_top.v` | — | Structural instantiation of `uart_tx` + `uart_rx`, single synthesis entry point for OpenLane |

> **Why mid-bit sampling matters:** the receiver has no shared clock with the transmitter. Sampling at the exact midpoint of each bit period — rather than at the edge — gives maximum margin against clock drift between the two devices before the signal is misread.

### 1.2 Baud Rate Timing

```
CLKS_PER_BIT = clock_frequency / baud_rate = 50,000,000 / 9600 ≈ 5208
```

50MHz clock, 9600 baud → each bit holds the line for 5208 clock cycles (~104µs). `clk_count` is sized at 13 bits (2¹³ = 8192 > 5208).

---

## 2. Timing Constraints (SDC)

| Constraint | Value | Real-World Meaning |
|---|---|---|
| `create_clock -period 20` | 20ns (50MHz) | Total time budget per clock cycle |
| `set_clock_uncertainty` | 0.5ns | Safety margin for clock jitter — accounts for real silicon's imperfect clock edges |
| `set_input_delay -max` | 4ns | Time already consumed by upstream off-chip logic before signal reaches our input pins |
| `set_output_delay -max` | 4ns | Time reserved for downstream off-chip logic after our output leaves the chip |
| `set_false_path -from rst_n` | — | Reset is asynchronous infrastructure, not a timed data path |

> **Why `tx_start` does NOT get a false path like `rst_n`:** `rst_n` has no functional timing relationship to the clock — it's correctness infrastructure. `tx_start` is a real synchronous control signal that triggers the FSM and must meet setup/hold like any data signal.

Effective internal logic budget per cycle: `20ns − 4ns (input delay) − 0.5ns (uncertainty) ≈ 15.5ns`.

---

## 3. Synthesis

Yosys converts behavioral Verilog into a real SKY130 standard-cell gate netlist.

| Metric | Result |
|---|---|
| Total cells | 267 |
| Flip-flops (`dfxtp_2`) | 60 |
| Chip area | 3034.16 µm² |
| Sequential area | 1276.22 µm² (42.06%) |
| CHECK pass problems | 0 |
| Dead case branches removed | 2 (`default: state <= IDLE` in both FSMs — provably unreachable since all 4 values of a 2-bit `state` are already covered) |

### 3.1 FSM Re-encoding — Binary → One-Hot

Yosys's `FSM_RECODE` pass automatically re-encoded both FSMs:

| State | Binary (RTL) | One-Hot (Synthesized) |
|---|---|---|
| IDLE | `00` | `0001` |
| START | `01` | `0100` |
| DATA | `10` | `0010` |
| STOP | `11` | `1000` |

> **Trade-off:** one-hot costs 2 extra flip-flops per FSM (4 total across TX+RX) but simplifies next-state decode logic to single-bit checks instead of 2-bit comparisons — Yosys judged this the better trade for this design's size.

---

## 4. Floorplan

| Parameter | Value |
|---|---|
| Die area | 98.135 × 108.855 µm |
| Core area | 86.94 × 87.04 µm |
| Core utilisation target (`FP_CORE_UTIL`) | 40% |
| Placement grid | 32 rows × 189 sites |
| Site dimensions | 0.46 µm (W) × 2.72 µm (H) |

Verification: `3034.16 µm² (cell area) / 7567 µm² (core area) ≈ 40.1%` ✅ matches target.

> **Why core area > cell area, and die area > core area:** the gap between core and die holds I/O pins and the power ring. The gap between cell area and core area (60% empty at 40% utilisation) is reserved for routing channels — wires need room to connect cells without overlapping.

![Floorplan](images/01_floorplan.png)
*Empty 32×189 placement grid with power rails (VPWR/VGND) and I/O pin locations, before any cells are placed*

---

## 5. Placement

| Metric | Value |
|---|---|
| Final cell count | 455 (267 logic + 102 tap + 64 fill + 22 timing repair buffers) |
| Original HPWL (global placement) | 3925.2 µm |
| Legalized HPWL (snapped to rows/sites) | 4127.8 µm (+5%) |
| After detailed placement (116 instances mirrored) | 3925.2 µm (−4.9%) |
| Total/avg/max displacement | 0.0 µm (global placement was already legal) |

> **Tap cells (102):** connect the substrate/well to power rails at regular intervals — prevent **latch-up**, a destructive parasitic current path. Manufacturing requirement, not functional.
> **Fill cells (64):** plug gaps in rows where SKY130 requires continuous diffusion/well layers. No logic function.
> **HPWL (Half-Perimeter Wire Length):** a fast geometric estimate (half the bounding-box perimeter of a net's pins) — analogous to *displacement* in physics. It is not the real routed wire length, which is computed later and is typically longer since real wires must navigate around obstacles and obey per-layer direction rules.

![Placement](images/02_placement.png)
*455 cells placed into the row grid, with met1 routing-layer geometry visible inside standard cells*

---

## 6. Clock Tree Synthesis

TritonCTS builds an **H-tree** — symmetric buffer/wire structure distributing `clk` to all 60 flip-flops with minimal skew.

| Metric | Value |
|---|---|
| Clock roots | 1 |
| Buffers inserted (core H-tree) | 9 |
| Tree depth (max level) | 3 |
| Sinks (flip-flops) | 60 |
| Min/max buffer hops to any flip-flop | 2 / 2 |
| Root buffer / sink buffer | `clkbuf_16` / `clkbuf_8` |
| Final clock-related cells (post-repair) | 12 clock buffers + 4 clock inverters |
| **Real measured clock skew** | **~1.6 picoseconds** (0.218679ns − 0.217077ns between two flops) |

> **The skew result that matters most:** the H-tree's structural symmetry (every flip-flop exactly 2 buffer hops from root, roughly equal wire length per level) drove *real* skew down to ~1.6ps — essentially negligible. The `0.5ns` figure that dominates the formal "setup skew" calculation in STA is almost entirely the **designed-in clock uncertainty margin from the SDC**, not actual clock-tree skew. The H-tree over-delivered; the conservative SDC margin was the real cost.

![Clock Tree Synthesis](images/03_cts.png)
*Clock buffers (clkbuf_16/clkbuf_8) inserted across the placement grid, forming the H-tree*

---

## 7. Routing — Global & Detailed

### 7.1 Global Routing (coarse path planning)

| Metric | Value |
|---|---|
| Routing layers used | met1 (horizontal) ↔ met2 (vertical) ↔ met3 (horizontal), met4/met5 unused |
| Total congestion usage | 14.20% (met1 21.86%, met2 23.07%, met3 0.21%, met4/5 0%) |
| Overflow (any layer, any region) | **0** |
| Total wirelength (estimate) | 11,847 µm |
| Routed nets | 439 |
| Antenna violations | 0 net / 0 pin |

> **Antenna effect:** during fabrication, a long isolated metal wire can accumulate static charge before it's connected to its protecting transistor, potentially damaging the thin gate oxide. Zero violations means no wire shape is at risk of this.

> Met1/met2 dominate demand because every standard-cell pin physically lives on `li1`/`met1`, and this design is small enough that almost no connection needs to travel far enough to require met3+.

### 7.2 Detailed Routing (exact, DRC-legal geometry)

| Metric | Value |
|---|---|
| **DRC violations** | **0** (iteratively reduced: 3 → 2 → 1 → 0) |
| Real wirelength | 6394 µm — met1 3417 (53%), met2 2919 (46%), met3 57 (<1%) |
| Total vias | 2525 (li1↔met1: 1311+1195, met1↔met2: 19) |

> Real wirelength (6394µm) came out *shorter* than global routing's coarse estimate (11,847µm) — global routing intentionally overestimates to leave margin; detailed routing found tighter, exact paths.

![Routing](images/04_routing.png)
*Final routed metal geometry — met1/met2 wires connecting all 455 placed cells*

---

## 8. Static Timing Analysis — Sign-off

STA verifies real, extracted timing across **9 PVT corners** (Process/Voltage/Temperature combinations) — not just one "ideal" condition.

| Corner/Group | Hold Worst Slack | Setup Worst Slack | Violations |
|---|---|---|---|
| **Overall** | **0.1440 ns** | **10.5515 ns** | **0** |
| nom_tt_025C_1v80 (typical) | 0.4860 ns | 13.1586 ns | 0 |
| max_ss_100C_1v60 (slowest) | 1.4609 ns | 10.5515 ns | 0 |
| min_ff_n40C_1v95 (fastest) | 0.1440 ns | 14.0163 ns | 0 |

✅ **Zero setup/hold violations across every corner.** Max cap and max slew violations: 0.

### 8.1 Why setup and hold fail at opposite corners

Setup checks "is the path fast enough" — hardest when everything runs slow → **worst at `ss` (slow-slow)**.
Hold checks "did new data race ahead too fast" — hardest when everything runs fast → **worst at `ff` (fast-fast)**.
Confirmed exactly by this data: worst setup at `max_ss_100C_1v60`, worst hold at `min_ff_n40C_1v95`.

### 8.2 Setup vs. Hold — the core distinction

| | Setup | Hold |
|---|---|---|
| Deadline | Next clock edge (20ns away) | Same clock edge (~0ns away) |
| Fixed by | Faster cells, slower clock helps | Adding delay buffers — **slower clock does NOT help** |
| Why clock period is irrelevant to hold | The race is glued to the launching edge itself, not to the gap between edges | — |

### 8.3 Worst Hold Path (traced)

```
Startpoint: _457_ (u_uart_rx, clk_count[5])
Endpoint:   _440_
Clock path: clk → clkbuf_16 (root) → clkbuf_16 (leaf) → _457_/CLK   [2 hops, confirms H-tree depth]
Data path:  Q → and2 → o31a → o21ai → nand2 → and2 → D
Data arrival time: 0.843845 ns   →   Hold slack: 0.1440 ns
```

This is the comparator chain from `clk_count < CLKS_PER_BIT - 1` — 5 real gate delays provided enough natural delay to clear the hold requirement comfortably.

---

## 9. DRC & LVS Sign-off

> **Why run DRC again, when detailed routing already checked it?** The routing-stage DRC check (Section 7.2) was performed by OpenROAD's own internal rule-checker. Sign-off DRC is run by two **completely independent** tools — Magic and KLayout, each with its own rule-checking engine reading SkyWater's official rule deck directly — so no single tool's verdict is ever trusted alone before tapeout.
>
> **IR Drop (encountered as a flow warning, not deeply analysed here):** real power-rail metal has resistance, so the supply voltage measured far from the power pad is always slightly lower than at the pad itself — this voltage "sag" is called IR drop. OpenLane flagged that a full IR drop analysis would need additional setup (`VSRC_LOC_FILES`) not provided in this project; not a concern at this design's size, but a real consideration on larger chips.

| Check | Tool | Result |
|---|---|---|
| DRC | Magic | ✅ Clear |
| DRC | KLayout | ✅ Clear (independent cross-check) |
| LVS | Netgen | ✅ **Circuits match uniquely** |

### 9.1 LVS Detail

```
Number of devices: 442  |  Number of devices: 442
Number of nets:    448  |  Number of nets:    448
Netlists match uniquely.
Final result: Circuits match uniquely.
```

All 25 pins (clk, rst_n, tx_data[7:0], tx_start, rx_data[7:0], tx_out, tx_done, rx_done, VPWR, VGND) confirmed identical between the GDSII-extracted netlist and the original synthesized netlist.

> **Why LVS matters even after clean DRC:** DRC verifies *shapes* obey manufacturing rules. LVS verifies the shapes form the *correct circuit*. A dropped via or shorted net could pass DRC perfectly while being electrically wrong — LVS is the only check that catches this.

---

## 10. GDSII Export

Three GDSII files generated:

```
uart_top.gds            ← canonical output
uart_top.magic.gds      ← Magic stream-out
uart_top.klayout.gds    ← KLayout stream-out
```

> **On the XOR cross-check:** `KLayout.XOR` / `Checker.XOR` runs automatically between the Magic and KLayout stream-outs as part of this same flow, comparing their exported geometry shape-by-shape. The full run completed with zero ERROR lines through this step and on into a clean DRC/LVS sign-off — strong evidence the two exports agree — though the exact diff report itself wasn't separately inspected in this session.

![Final GDSII Layout](images/05_gdsii_final.png)
*Complete, signed-off physical layout — ready for foundry submission*

---

## 11. Results Summary

### 11.1 Cell Count Growth Across Stages

| Stage | Total Cells | Area (µm²) | What Was Added |
|---|---|---|---|
| Synthesis | 267 | 3034.16 | Base logic + 60 flip-flops |
| Placement | 455 | 3241.86 | + 102 tap, 64 fill, 22 timing repair buffers |
| CTS | 471 | 3597.20 | + 12 clock buffers, 4 clock inverters |
| Global Routing | 600 | 4888.44 | + 129 additional timing repair buffers (22 → 151) after real wire estimates exposed new slew violations |
| Detailed Routing | 600 | 4888.44 | No change — routing finalises wire geometry only, adds no cells |

> Each stage's growth reflects the "fix early, fix cheap" principle: every category of cell (tap, fill, buffer) was added by the tool the moment it had enough information to detect a real problem — manufacturing rules, timing slew, or wire-length — rather than waiting until a later, more expensive stage.

### 11.2 Final Sign-off Results

| Stage | Metric | Result | Status |
|---|---|---|---|
| Synthesis | Cell count / FFs / Area | 267 / 60 / 3034.16 µm² | ✅ |
| Synthesis | CHECK pass problems | 0 | ✅ |
| Floorplan | Core utilisation | 40.1% (target 40%) | ✅ |
| Placement | Displacement | 0.0 µm | ✅ |
| Placement | HPWL optimisation | 4127.8 → 3925.2 µm | ✅ |
| CTS | Real clock skew | ~1.6 ps | ✅ |
| CTS | Buffer hops (min/max) | 2 / 2 | ✅ |
| Global Routing | Congestion overflow | 0 | ✅ |
| Global Routing | Antenna violations | 0 / 0 | ✅ |
| Detailed Routing | DRC violations | 0 | ✅ |
| STA | Setup violations (9 corners) | 0 | ✅ |
| STA | Hold violations (9 corners) | 0 | ✅ |
| STA | Worst setup / hold slack | 10.55 ns / 0.144 ns | ✅ |
| Sign-off DRC | Magic + KLayout | Both clear | ✅ |
| Sign-off LVS | Netgen | Match uniquely | ✅ |
| GDSII | Export (Magic + KLayout, XOR step ran cleanly) | 3 GDS files generated | ✅ |

---

## 12. Engineering Discussion & Design Decisions

### Why 50MHz?
Chosen as a realistic, comfortable peripheral clock for SKY130 130nm at this logic complexity — UART-class peripherals in real SoCs typically run well below the core clock (often 50-100MHz off a clock divider), since the external protocol itself (9600 baud here) needs very few cycles per bit. The resulting 10.55ns of setup margin reflects how undemanding this target is for the process — appropriate for a first physical-design project, where the goal is verifying full-flow execution rather than pushing a process to its frequency limit.

### Why 40% core utilisation?
A conservative, common starting point that leaves 60% of the core empty for routing channels. The result (14.2% global routing usage, 0 overflow) shows this was generous headroom for a design this small — a real project might push utilisation higher (60-70%) to reduce die area/cost, at the expense of routing margin.

### Why is hold margin (0.144ns) so much tighter than setup margin (10.55ns)?
Setup slack scales directly with clock period — a slow 50MHz clock gives setup almost "free" margin. Hold timing is independent of clock period entirely; it depends only on the spread between fastest and slowest possible path delay. This is exactly why 151 timing repair buffers were inserted by the post-routing repair pass — purely to protect hold margin, since slowing the clock would have done nothing for it.

### Tool-version mismatches were the single biggest time cost
Far more debugging time went into making the OpenLane/Yosys/Docker toolchain function correctly on WSL2 than into the RTL or PD concepts themselves. See Section 13 for the full log — this is itself a real, transferable skill: production EDA environments are frequently this fragile, and the patience to systematically root-cause a tool failure (rather than giving up or guessing) is part of the actual job.

---

## 13. Environment Setup & Debugging Log

Running OpenLane 2 + Yosys + OpenROAD on WSL2 Ubuntu 22.04 required resolving several non-obvious issues:

| Issue | Root Cause | Fix |
|---|---|---|
| Verilator lint crash: `Unknown warning specified: -Wno-EOFNEWLINE` | Ubuntu apt's Verilator (4.038, 2020) too old for the flag OpenLane 2 passes | Skip lint stage: `--from Yosys.Synthesis` |
| `yosys: command not found` | `yowasp-yosys` (WebAssembly Yosys) installed under a different binary name | Initially symlinked `yosys` → `yowasp-yosys`; insufficient (see below) |
| `Option 'y' does not exist` | `yowasp-yosys` lacks `ENABLE_PYOSYS` — no embedded Python scripting support, but OpenLane calls `yosys -y script.py` | Required a real Yosys build with Pyosys support |
| `ModuleNotFoundError: No module named 'pyosys'` after wrapper hack | OSS CAD Suite's bundled Python (3.11) ≠ system Python (3.10) where `pip install pyosys` landed | Hardcoded wrapper to call `/usr/bin/python3` explicitly |
| `AttributeError: pyosys.libyosys.Pass has no attribute call__YOSYS_NAMESPACE...` | `pip install pyosys` version's C++ API didn't match what OpenLane 2.3.10's internal scripts expected | **Root fix: switch to `--dockerized`** — OpenLane's official Docker image bundles a correctly-matched Yosys/Pyosys build; this is the officially recommended install path for exactly this reason |
| `SetPowerConnections: missing required input 'JSON_HEADER'` | Resuming with `--from Yosys.Synthesis` skips the earlier `Yosys.JsonHeader` step that later steps depend on | Always resume from `--from Yosys.JsonHeader` once steps beyond synthesis are needed |
| Deprecated config warnings (`SDC_FILE`, `DESIGN_IS_CORE`, `PL_TARGET_DENSITY`) | OpenLane 2 renamed several config keys | Use `FALLBACK_SDC_FILE`, `FP_PDN_MULTILAYER`, `PL_TARGET_DENSITY_PCT` |
| `no step(s) with ID 'synthesis' found` | OpenLane 2 namespaces every step by tool (`Yosys.Synthesis`, not `synthesis`) | List exact step IDs via `Flow.factory.get("Classic").Steps` in a Python one-liner |
| KLayout 0.26.2 crashes on launch (`SaltDownloadManager` segfault) | Known bug when KLayout's online package-update check runs in an offline/restricted WSL2 environment | Launch with `klayout -nn -e` to disable the Salt manager |
| KLayout can't connect to display | WSL2's host IP (for X11 via VcXsrv) can change after a Windows restart; naive `.bashrc` interpolation broke `$DISPLAY` | `export DISPLAY=$(ip route show default | awk '{print $3}'):0` |
| DEF/LEF dialog can't find `.volare` PDK path | Hidden folder, plus long error-prone paths to type into a GUI dialog | `Ctrl+H` to show hidden folders, or create short local symlinks (`tech.tlef`, `cells.lef`) inside the project directory |
| `DRT-0349 LEF58_ENCLOSURE with no CUTCLASS is not supported` | Known TritonRoute limitation with certain newer SKY130 LEF rule syntax for the `mcon` layer | Non-fatal — one specific rule check skipped, routing still completes DRC-clean |

---

## Supporting Documents

| File | Contents |
|---|---|
| [`reports/synthesis.log`](reports/synthesis.log) | Full Yosys synthesis log — AST parsing, optimization passes, FSM detection and re-encoding |
| [`reports/openroad-floorplan.log`](reports/openroad-floorplan.log) | Die/core area calculation, row/site grid generation |
| [`reports/openroad-detailedplacement.log`](reports/openroad-detailedplacement.log) | HPWL optimization, cell mirroring, displacement analysis |
| [`reports/cts.rpt`](reports/cts.rpt) | Clock tree buffer count, sink count, fanout distribution |
| [`reports/global_routing.log`](reports/global_routing.log) | Per-layer congestion analysis, wirelength, antenna check |
| [`reports/detailed_routing.log`](reports/detailed_routing.log) | DRC violation iteration log, final via/wirelength counts |
| [`reports/sta_summary.rpt`](reports/sta_summary.rpt) | Full WNS/TNS table across all 9 PVT corners |
| [`reports/lvs.netgen.rpt`](reports/lvs.netgen.rpt) | Full device/net match report from Netgen LVS |
| [`gds/uart_top.gds`](gds/uart_top.gds) | Final manufacturing-ready GDSII file |

> A `docs/pd_notes.md` study-guide-style writeup (design decisions, debugging journey, interview prep) is planned as a future addition, in the same spirit as a project retrospective — not yet written as of this commit.

---

## 14. Key Equations Quick Reference

| Parameter | Formula | This Design |
|---|---|---|
| Clocks per bit | `clock_freq / baud_rate` | 50,000,000 / 9600 ≈ 5208 |
| Core area from utilisation | `cell_area / utilisation` | 3034.16 / 0.40 ≈ 7585 µm² |
| Internal logic time budget | `clock_period − input_delay − uncertainty` | 20 − 4 − 0.5 = 15.5 ns |
| Setup slack | `Required Time − Arrival Time` | worst case: 10.5515 ns |
| Hold slack | `Arrival Time(min) − Required Time(min)` | worst case: 0.1440 ns |
| Data arrival time | `clock latency + clock-to-Q + Σ(gate delay + wire delay)` | e.g. 0.843845 ns (traced hold path) |
| HPWL (estimate only) | half-perimeter of net's pin bounding box | 3925.2 µm (vs. 6394 µm real routed) |
