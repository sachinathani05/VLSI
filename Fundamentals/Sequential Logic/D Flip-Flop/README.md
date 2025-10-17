## 🧩 D Flip-Flop

### 🔍 Description

The D (Data or Delay) Flip-Flop captures the input D on the rising or falling edge of the clock and outputs it at Q.
Used for data storage and synchronization.

### ⚙️ Working
- On clock = HIGH edge, Q = D.
- Otherwise, output holds previous value.

### 🧠 Truth Table
| D | CLK | Q(next) |
| - | --- | ------- |
| 0 | ↑   | 0       |
| 1 | ↑   | 1       |
| – | 0   | Q(prev) |

### ▶️ How to Run
1. Connect clock input.
2. Toggle D and apply clock pulse.
3. Observe Q following D on rising edge.
