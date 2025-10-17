## 🧩 PIPO (Parallel-In Parallel-Out)
### 🔍 Description
All bits of data are loaded in parallel and output in parallel.
Used for temporary data storage or register transfer operations.

### 🧠 Truth Table
| Load | Input (D3 D2 D1 D0) | Output (Q3 Q2 Q1 Q0) |
| ---- | ------------------- | -------------------- |
| 0    | XXXX                | Q (no change)        |
| 1    | 1010                | 1010                 |

### ▶️ How to Run
1. Set inputs (D0–D3).
2. Enable Load signal.
3. Observe outputs reflect input pattern.
