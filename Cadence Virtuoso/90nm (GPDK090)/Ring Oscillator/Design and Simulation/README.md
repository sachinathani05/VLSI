# ⚙️ 1. Cadence Virtuoso Design Steps

## 1.1 Create the Schematic

### **➤ New Schematic**
File → New → Cell View
Library: your library
Cell Name: Ring_Oscillator
View: schematic

### **➤ Place Components**
1. Press **i** to place **three inverters**.
2. Connect them in series.
3. Connect the last inverter output back to the first input (feedback).
4. From **analogLib**, place a **vdc** source and **gnd**:
  - Set voltage = **1.2 V**
- Connect postive to `VDD` of all inverter and negative terminal to `gnd`.
5. Connect `GND` of all 3 inverter to `gnd` 

---

# 🧪 2. Simulation in ADE L

## 2.1 Open ADE L
Launch → ADE L

Ensure simulator = **Spectre**.

---

## 2.2 Transient Analysis Setup
Analyses → Choose…
Type: tran
Stop time: 20n

---

## 2.3 Select Output
Outputs → To be plotted → Select on schematic

Choose any inverter output node (3rd Inverter output).

---

## 2.4 Add Initial Condition (Important)
Ring oscillator may not start without an initial offset.

Simulation → Convergence Adis → Node Set
Node: /inv1_in
Value: 0.1

Simulation → Convergence Adis → Initial Condition
Node: /inv1_in
Value: 0

---

## 2.5 Run Simulation
Click **Run**.

You should see oscillations.

---

# 📏 3. Measuring Frequency

In the waveform viewer:
Markers → Delta Markers → Horizontal

Place markers on two rising edges:

\[
f = \frac{1}{T}
\]

## Below is the calculation based on value obtained after simulations. 
## Measured Values

- **Oscillation Period:**  
  `T = 0.69 ns`

- **Number of Stages:**  
  `N = 3`

---

## Calculations

### 1. Frequency

\[
f = \frac{1}{T}
\]

\[
f = \frac{1}{0.69 \times 10^{-9}} \approx 1.449 \times 10^{9}\ \text{Hz}
\]

**Frequency ≈ 1.45 GHz**

---

### 2. Per-Inverter Delay

For an odd-stage ring oscillator:

\[
T = 2 N t_p
\]

Solve for inverter delay:

\[
t_p = \frac{T}{2N}
\]

\[
t_p = \frac{0.69 \times 10^{-9}}{6} = 0.115 \times 10^{-9}\ \text{s}
\]

**Inverter delay ≈ 115 ps**

---

## Result Summary

| Parameter | Value | Notes |
|----------|--------|-------|
| Period (T) | **0.69 ns** | From simulation waveform |
| Frequency (f) | **1.45 GHz** | Matches theory |
| Inverter delay (tp) | **115 ps** | Typical for 90 nm CMOS |

---

## Validation Against 90 nm CMOS Data

| Metric | Typical Range | Your Result | Check |
|--------|----------------|-------------|-------|
| Period | 0.6–1.2 ns | **0.69 ns** | ✔ Valid |
| Frequency | 0.8–1.6 GHz | **1.45 GHz** | ✔ Matches |
| Inverter delay | 100–150 ps | **115 ps** | ✔ Correct |

Your simulated results fall exactly within realistic 90 nm technology behavior, confirming proper sizing, load, and simulation setup.

---

## Conclusion

- **Oscillation period:** 0.69 ns  
- **Frequency:** 1.45 GHz  
- **Inverter delay:** 115 ps  

All results are consistent with expected gpdk090 CMOS performance.


---

# 🔄 4. Parametric Sweep (Impact of Sizing)

### Step 1 — Parameterize Inverter Width
Edit inverter NMOS/PMOS:

Wn = wn_ratio * 180n
Wp = wp_ratio * 360n

### Step 2 — Load Variables
Variables → Copy from Cellview

### Step 3 — Parametric Analysis
Tools → Parametric Analysis
Variable: wp_ratio
Range: 1 to 5
Step: 1
Run


---

# ⚡ 5. Frequency Example

| Wp_ratio | Frequency (MHz) | Power (µW) |
|---------|-----------------|------------|
| 1       | 288.4             | 32.2         |
| 2       | 484.6             | 63.9         |
| 3       | 626.1             | 95.4         |
| 4       | 732.7             | 126.9         |
| 2       | 816.2             | 159.0         |

Trend:  
Higher W → lower delay → higher frequency (but more power).

Use calculator to get values. 
1. From waveform tab > Tool > Calculator. Chose waveform for which the value needs to be calculated.
   Select Frequency from special funtion on calculator to get frequency value.
2. To calculator power, add current parameter value in the output by selecting Vdc componect.
   Use calculator to get the average current value by selecting wave and multipl with 1.2 (source voltage).
   

---

# NOTE : 
1. If the time period does not match the expected value, add fixed external load capacitamce (10fF to 20fF).
2. Increase channel Lenght of nMOS and pMOS 
Longer L → lower drive current (IDS) → higher resistance → larger RC time constant → larger tp → longer period (T).
