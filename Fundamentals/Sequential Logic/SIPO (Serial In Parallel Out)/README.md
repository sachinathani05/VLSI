## 🧩 SIPO (Serial-In Parallel-Out)
### 🔍 Description

Data is entered serially, one bit at a time, and after several clock pulses, the bits appear in parallel at outputs.
Used in data reception and deserialization.

### 🧠 Truth Table (4-bit example)
| Clock | Serial In | Q3 | Q2 | Q1 | Q0 |
| ----- | --------- | -- | -- | -- | -- |
| 1     | 1         | 0  | 0  | 0  | 1  |
| 2     | 0         | 0  | 0  | 1  | 0  |
| 3     | 1         | 0  | 1  | 0  | 1  |
| 4     | 0         | 1  | 0  | 1  | 0  |

### ▶️ How to Run
1. Connect Serial Input and Clock.
2. Feed input bits sequentially.
3. After 4 pulses, check parallel outputs.
