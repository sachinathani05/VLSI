# 🧱 CMOS Inverter Layout Verification — DRC & LVS (GPDK090)


This stage focuses on **creating, verifying, and validating** your CMOS inverter layout using **Cadence Virtuoso Layout XL** with the **GPDK090** technology kit.  
The process ensures that your physical design follows all fabrication rules (DRC) and matches your schematic (LVS).

---

## 🧩 1️⃣ Create Inverter Layout in Virtuoso Layout XL

### **Steps**
1. **Open schematic:** Launch → Layout XL
- Choose **Use Existing Schematic**
- Create new **layout view**

2. **Setup Technology:**
- Ensure **GPDK090** tech file is active  
- Layers: diffusion, poly, metal1, contact (MCON), nwell, pwell

3. **Generate layout pins and devices:** Connectivity → Generate → All From Source
   
4. **Place devices:**
- PMOS on top (in n-well)
- NMOS on bottom (in p-substrate)
- Align drains vertically → Output (VOUT)
- Connect:
  - PMOS Source → VDD
  - NMOS Source → GND
  - PMOS/NMOS Drain → VOUT
  - PMOS/NMOS Gate → VIN

5. **Define Pins:** Create → Pin
- `VIN`, `VOUT`, `VDD`, `GND` (use Metal1 layer)

6. **Save & Check:** Design → Check and Save


---

## 🧹 2️⃣ Design Rule Check (DRC)

### **Steps**
1. Open: Verify → DRC
2. Check “Rules File” points to your **gpdk090.tf**  
3. Run the check.  
4. Observe errors in the **layout window**:
- **Spacing violation** → two shapes too close
- **Width violation** → too narrow line
- **Enclosure** → contact not covered properly

5. Fix issues → Re-run DRC until: No DRC errors found


---

## 🔍 3️⃣ Layout vs Schematic (LVS)

### **Steps**
1. Open: Verify → LVS
2. Fill form:
| Field | Value |
|--------|--------|
| Library | Your project library |
| Cell | CMOS_Inverter |
| Source View | schematic |
| Layout View | layout |
| Run Directory | default or custom folder |

3. Enable **Run Extracted View** if available  
4. Click **Run**

### **Check Report**
If `Results → LVS Debug` is not visible:
- Check CIW log for path (e.g. `~/Cadence/LVS/CMOS_Inverter/LVS.report`)
- Or navigate manually: ~/Cadence/LVS/<library>/<cell>/LVS/
Open:
- `LVS.report`
- `LVS.log`
- `avCompare.log` (if Assura)

**Success Example:**
LVS run completed successfully.
Devices matched: 2 of 2
Nets matched: 4 of 4
Pins matched: 4 of 4
Result: Layout and schematic match.


---

## ⚙️ Common LVS Fixes

| Issue | Cause | Fix |
|-------|--------|------|
| Unmatched net | Pin name mismatch | Ensure layout pins = schematic pins |
| Device mismatch | Wrong orientation | Flip/rotate device |
| Shorted nets | Overlapping metals | Separate and rerun DRC |
| Substrate error | Missing tie | Add P+/N+ substrate contacts |


---

## ✅ Summary Flow
Schematic → Layout XL → DRC → Fix → LVS → Match ✅

## 💡 Notes

- Use **gpdk090** PDK layer names as shown in your Layer Palette.
- Always re-run **DRC** before **LVS**.
- If LVS Debug menu is missing, always rely on `.report` file in the run directory.


