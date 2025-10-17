## 📈 Simulation Details

### 1️⃣ Transient Analysis

**Objective:** Observe inverter switching behavior with respect to a pulse input.  

**Setup:**
- Input: Pulse (0 V – VDD)
- Output: Observe voltage at output node
- Analysis: Transient (time-domain)

**Expected Result:**
- Output waveform is inverted compared to input.
- Shows **propagation delay**, **rise time**, and **fall time**.

  <p align="center">
  <img src="schematic/cmos_inv_dc_transfer.grf" width="500">
</p>
---

### 2️⃣ DC Transfer Characteristics

**Objective:** Plot **Vout vs. Vin** to determine switching threshold and noise margins.

**Setup:**
- Sweep Vin from 0 V → VDD
- Measure Vout at each step
- Plot transfer curve

**Expected Result:**  
Smooth S-shaped VTC with switching point ≈ VDD / 2.

<p align="center">
  <img src="schematic/cmos_inv_dc_transfer.grf" width="500">
</p>
