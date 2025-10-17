## 🧩 PISO (Parallel-In Serial-Out)
### 🔍 Description
Data is loaded in parallel and shifted out serially on each clock pulse.
Useful for data transmission over a single wire.

### 🧠 Truth Table (Example for 4-bit)
| Load | Clock     | Output (Serial Q) | Internal State (Q3 Q2 Q1 Q0) |
| ---- | --------- | ----------------- | ---------------------------- |
| 1    | X         | -                 | 1010 (load)                  |
| 0    | 1st pulse | 0                 | 0101                         |
| 0    | 2nd pulse | 1                 | 0010                         |
| 0    | 3rd pulse | 0                 | 0001                         |
| 0    | 4th pulse | 1                 | 0000                         |

### ▶️ How to Run
1. Load data (D3–D0) → Load = 1010.
2. Disable Load.
3. Apply clock → observe bits shifting out on each pulse.
