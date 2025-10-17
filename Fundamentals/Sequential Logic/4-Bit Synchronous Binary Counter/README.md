# 🧩 4-Bit Synchronous Binary Counter

## 🔍 Description

All flip-flops are triggered simultaneously by a common clock.
Combinational logic between stages ensures correct binary counting.
This avoids propagation delay issues present in ripple counters.

## ⚙️ Working

- FF0 toggles on each pulse.
- FF1 toggles when Q0 = 1 and clock edge arrives.
- FF2 toggles when Q0 & Q1 = 1, and so on.


## 🧠 Truth Table
 | Clock Pulses | Q3 | Q2 | Q1 | Q0 |
| ------------ | -- | -- | -- | -- |
| 0            | 0  | 0  | 0  | 0  |
| 1            | 0  | 0  | 0  | 1  |
| 2            | 0  | 0  | 1  | 0  |
| 3            | 0  | 0  | 1  | 1  |
| 4            | 0  | 1  | 0  | 0  |
| 5            | 0  | 1  | 0  | 1  |
| 6            | 0  | 1  | 1  | 0  |
| 7            | 0  | 1  | 1  | 1  |
| 8            | 1  | 0  | 0  | 0  |
| 9            | 1  | 0  | 0  | 1  |
| 10            | 1  | 0  | 1  | 0  |
| 11            | 1  | 0  | 1  | 1  |
| 12            | 1  | 1  | 0  | 0  |
| 13            | 1  | 1  | 0  | 1  |
| 14            | 1  | 1  | 1  | 0  |
| 15            | 1  | 1  | 1  | 1  |

## ▶️ How to Run
1. Connect clock to all FFs.
2. Use AND gates for enable control signals.
3. Step the clock → observe Q0–Q3 counting synchronously.
