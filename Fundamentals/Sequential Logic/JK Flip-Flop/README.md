## 🧩 JK Flip-Flop
### 🔍 Description

Versatile FF that can act as SR, T, or D depending on inputs.
Triggered on clock edge.

### 🧠 Truth Table
| J | K | CLK | Q(next)  |
| - | - | --- | -------- |
| 0 | 0 | ↑   | Q(prev)  |
| 0 | 1 | ↑   | 0        |
| 1 | 0 | ↑   | 1        |
| 1 | 1 | ↑   | ¬Q(prev) |

### ▶️ How to Run
1. Connect J, K, and Clock.
2. Toggle inputs and apply clock pulse.
3. Observe how Q updates on each edge.
