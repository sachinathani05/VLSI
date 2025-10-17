## 🧱 Layout Design 
### Steps to Build Layout

### ⚙️ Technology & Simulation Setup

| Parameter | Value / Library |
|------------|----------------|
| PDK | gpdk090 |
| Supply Voltage (VDD) | 1.2 V |
| Channel Length (L) | 0.10 µm |
| NMOS Width (Wn) | 1.0 µm |
| PMOS Width (Wp) | 2.5 µm |
| Output Load Capacitance (CL) | 10 fF |
| Input Source (DC) | analogLib → `vdc` |
| Input Source (Transient) | analogLib → `vpulse` |
| Ground | analogLib → `gnd` |

---

### 🧩 Step-by-Step Design Flow

#### 1️⃣ Create Library and Schematic

1. Launch Virtuoso  
   ```bash
   virtuoso &
2. Library Manager → File → New → Library
   - Name: cmos_inv_lib
   - Attach to technology: gpdk090

3. Create New Cellview
   - Cell Name: cmos_inverter
   - View: schematic
   - Tool: Composer-Schematic

#### 2️⃣ Place Components
| Component      | Library   | Cell   | View   |
| -------------- | --------- | ------ | ------ |
| PMOS           | gpdk090   | pmos   | symbol |
| NMOS           | gpdk090   | nmos   | symbol |
| VDD source     | analogLib | vdc    | symbol |
| GND            | analogLib | gnd    | symbol |
| Input source   | analogLib | vpulse | symbol |
| Load capacitor | analogLib | cap    | symbol |


#### 3️⃣ Connect the Circuit
| Node     | Connection                                  |
| -------- | ------------------------------------------- |
| **VDD**  | PMOS source, vdc(+)                         |
| **GND**  | NMOS source, vdc(–), vpulse(–)              |
| **Vin**  | Both transistor gates, vpulse(+)            |
| **Vout** | Common drain of NMOS & PMOS, connects to CL |

🧠 Note:
Ensure PMOS bulk → VDD, NMOS bulk → GND.

#### 4️⃣ Set Device Parameters
| Device | Width (W) | Length (L) | Multiplier (M) |
| ------ | --------- | ---------- | -------------- |
| NMOS   | 1.0 µm    | 0.10 µm    | 1              |
| PMOS   | 2.5 µm    | 0.10 µm    | 1              |


- Adjust Wp/Wn ≈ 2.5× to balance switching.
- If warning L < 100n appears, set L = 0.10u (PDK limit).

#### 5️⃣ DC Sweep (Voltage Transfer Characteristic)
Input Source: Replace vpulse with vdc temporarily.

1. ADE L → Analyses → Choose → dc
   - Sweep variable: Vin (vdc instance)
   - Range: 0 V → 1.2 V
   - Step: 0.01 V

2. Outputs → To be Plotted → Select on Schematic
   - Select Vout node.
3. Run simulation → Observe Vout vs Vin curve (VTC).

✅ Expected behavior:
Smooth transition from Vout = 1.2 V → 0 V as Vin increases from 0 V to 1.2 V.

📈 Switching Threshold (Vm):
Point where Vin = Vout (≈ 0.6 V for balanced design).

#### 6️⃣ Transient Analysis (Dynamic Response)
Input Source: Use vpulse

| Parameter      | Value |
| -------------- | ----- |
| V1             | 0 V   |
| V2             | 1.2 V |
| Delay          | 0 s   |
| Rise Time (tr) | 50 ps |
| Fall Time (tf) | 50 ps |
| Pulse Width    | 5 ns  |
| Period         | 10 ns |


ADE L → Analyses → Choose → tran
- Stop Time = 50 ns
- Add Vin and Vout as outputs
- Run simulation

✅ Expected Waveform:
- Vin: 0 ↔ 1.2 V square pulse
- Vout: Complementary inverted waveform

#### 7️⃣ Key Measurements
| Metric             | How to Measure                                            | Typical Result                 |
| ------------------ | --------------------------------------------------------- | ------------------------------ |
| **Vm**             | DC sweep → intersection of Vout & Vin                     | ≈ 0.6 V                        |
| **tPHL / tPLH**    | Time difference (50% VDD crossing) between input & output | ~100 ps–500 ps (depends on CL) |
| **Rise/Fall time** | Measure 10%–90% transition                                | Few × 10⁻¹⁰ s                  |
| **Noise margins**  | From VTC (optional)                                       | NMH, NML ≈ 0.4–0.5 V           |
