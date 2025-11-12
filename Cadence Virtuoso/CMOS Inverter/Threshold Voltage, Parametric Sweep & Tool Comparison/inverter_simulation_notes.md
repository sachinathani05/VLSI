# 🧪 CMOS Inverter Simulation Notes
### Tool: Cadence Virtuoso (gpdk090) + LTspice  
### Objective: Threshold Voltage, Noise Margins & Parametric Sweep Analysis

---

## 🧩 Step 1 — Schematic Creation

### ⚙️ Components
| Component | Description | Notes |
|------------|--------------|-------|
| NMOS | nmos4 (gpdk090) | Width = 1 µm, Length = 0.09 µm |
| PMOS | pmos4 (gpdk090) | Width = 2 µm (Wp/Wn = 2), Length = 0.09 µm |
| VDD | DC supply | 1.2 V |
| Vin | Input pulse/DC source | VIN type voltage source |
| CL | Load capacitor | 10 fF |
| GND | Global ground | Use **gnd!** (from analogLib) |

### ⚠️ Common Setup Errors
- **GND not connected properly:** Use `gnd!` from `analogLib`, not custom pin named "GND".  
- **Warnings like “terminal not found”** → check symbol pin names in schematic.
- Ensure **wires** do not cross without a solder dot.

---

## 🔍 Step 2 — DC Analysis (Switching Threshold & Noise Margins)

### 🧠 Purpose
To find **VM (switching threshold)** and observe the **VTC (Voltage Transfer Curve)**.

### 🧾 Procedure
1. Open **ADE L** → `Analyses → Choose → dc`.
2. Sweep **Vin** from `0 V → 1.2 V` (step = 0.01 V).
3. Set `Save All` in Outputs.  
4. Run simulation (`Netlist and Run`).
5. In **Waveform Viewer (ViVA)**, plot `Vout` vs `Vin` (select *plot vs parameter* if needed).
6. Use **Calculator → cross(VT("/Vout") - VT("/Vin"), 1)**  
   → Gives **Vin** where **Vout = Vin** (Switching threshold).

### ✅ Typical Result
VM ≈ 0.58–0.62 V (for Wp/Wn = 2)

---

## 📉 Step 3 — Transient Analysis (Propagation Delay)

### 🧠 Purpose
To measure **rise/fall delays** (tPLH, tPHL) from input to output.

### 🧾 Procedure
1. Replace DC source with **VPULSE**: V1 VIN 0 PULSE(0 1.2 0 100p 100p 5n 10n)
- Rise/fall time: 100 ps  
- ON time: 5 ns  
- Period: 10 ns
2. Set **Transient Analysis**: Stop Time = 20 ns
Step Time = 1 ps
3. Run simulation → plot `Vin` and `Vout`.
4. Measure delay using **Calculator → delay(VT("/Vin"), VT("/Vout"), 0.6, 'rising/falling)**`.

### ✅ Result Example
| Parameter | Symbol | Typical Value |
|------------|---------|----------------|
| tPLH | 0.35 ns |
| tPHL | 0.28 ns |
| Avg Power | 0.45 µW |

---

## 🧮 Step 4 — Parametric Sweep (W/L Ratio Effect)

### 🧠 Purpose
To study how **PMOS/NMOS sizing** affects switching point and delays.

### 🧾 Procedure
1. In schematic, define a variable for PMOS width: Wp = Wp_ratio * 1u
2. In ADE L → `Variables → Copy from Cellview`.
3. Set: Wp_ratio = 1.5:3.0:0.25
4. Go to `Tools → Parametric Analysis`.
5. Select output: `Vout` and measurements for VM, delay, power.
6. Run sweep.
7. Export data (`Results → Export → CSV`).

### ✅ Trend
- Higher Wp_ratio → higher VM.
- Slight increase in tPLH due to increased PMOS capacitance.
- Power consumption rises marginally.

---

## ⚖️ Step 5 — LTspice Simulation (Optional)

### 🧩 Schematic Setup
# ⚙️ CMOS Inverter Simulation in LTspice — Parametric Sweep of W/L Ratio

## 🎯 Objective
Replicate the Cadence Virtuoso CMOS inverter in **LTspice** and perform a **PMOS-to-NMOS width ratio (`Wp_ratio`) parametric sweep** to study its effect on:
- Voltage Transfer Characteristic (VTC)
- Trip Point (VM)
- Propagation Delay (tPLH, tPHL)
- Power Consumption

---

## 🧩 Step 1 — Create the Schematic
1. Open **LTspice** → `File → New Schematic`.
2. Press `F2` → search for and place **NMOS** and **PMOS** devices.
3. Connect as follows:
   - PMOS source → VDD
   - PMOS drain → output node `VOUT`
   - NMOS drain → output node `VOUT`
   - NMOS source → GND
   - Gates tied together → input node `VIN`
4. Add:
   - Voltage source `V1` for **VDD**
   - Pulse source `V2` for **VIN**
   - Capacitor `Cload = 10fF` between `VOUT` and GND
5. Label the nets as `VIN`, `VOUT`, `VDD`, and `0` (ground).

---

## 🧮 Step 2 — Add Model Definitions
Use **Spice Directive (S key)** and paste:

```spice
.model NMOSMOD NMOS (LEVEL=1 VTO=0.4 KP=120u LAMBDA=0.02)
.model PMOSMOD PMOS (LEVEL=1 VTO=-0.4 KP=40u LAMBDA=0.02)
```
## 📏 Step 3 — Define Transistor Parameters

Right-click NMOS → set: W = 1u, L = 0.1u

Right-click PMOS → set: W = {Wp_ratio * 1u}, L = 0.1u

Add the following Spice parameters:
```spice
.param VDD = 1.2
.param Wp_ratio = 2.5
.param Wn = 1u
```
⚡ Step 4 — Define Power and Input Sources

Add the following Spice directives:
```spice
V1 VDD 0 {VDD}
V2 VIN 0 PULSE(0 {VDD} 0 0.1n 0.1n 5n 10n)
```

This gives a square-wave input (period 10 ns, 50% duty cycle).

## 📈 Step 5 — DC Sweep (VTC)

Add:
```spice
.dc VIN 0 {VDD} 0.01
.plot dc V(VIN) V(VOUT)
```

Run the simulation → plot V(VOUT) vs V(VIN).

Observation:

Find the point where VOUT = VIN → that’s your trip point (VM).

## 🧠 Step 6 — Transient Analysis (Delay)

Add:
```spice
.tran 0.1n 20n
.meas tran tPLH TRIG V(VIN) VAL={VDD/2} FALL=1 TARG V(VOUT) VAL={VDD/2} RISE=1
.meas tran tPHL TRIG V(VIN) VAL={VDD/2} RISE=1 TARG V(VOUT) VAL={VDD/2} FALL=1
```

Run simulation and check SPICE Error Log (Ctrl + L) for measured delay values.

## 🔁 Step 7 — Parametric Sweep of Wp_ratio

Add:
```spice
.step param Wp_ratio 1.5 3.0 0.25
```

This sweeps the PMOS-to-NMOS width ratio from 1.5 to 3.0 in steps of 0.25.

After running:

Open waveform viewer → Plot Settings → Separate Curves

Hover over each curve to see Wp_ratio values

## ⚙️ Step 8 — Power Measurement (Optional)

Add:
```spice
.meas tran Pavg AVG V(VDD)*I(V1)
```

Power will appear in the .log file (check Ctrl + L).

## 📊 Step 9 — Export Results

1. In waveform window → File → Export Data as Text (.txt)
2. Choose V(VIN) and V(VOUT)
3. Save as Wp_ratio_sweep_results.txt
4. You can analyze delay or power vs. ratio in Excel or Python.


