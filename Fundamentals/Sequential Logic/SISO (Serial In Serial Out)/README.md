## 🧩 SISO (Serial-In Serial-Out)
### 🔍 Description

Data enters serially and exits serially.
Each bit moves one flip-flop ahead with each clock pulse — often implemented as a shift register chain.

### 🧠 Truth Table (Example)
| Clock | Input | Output |
| ----- | ----- | ------ |
| 1     | 1     | 0      |
| 2     | 0     | 1      |
| 3     | 1     | 0      |
| 4     | 0     | 1      |

### ▶️ How to Run
1. Connect Serial In and Clock.
2. Feed bits serially.
3. Observe output delayed by number of flip-flops.
