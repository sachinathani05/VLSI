## 🧩 4-Bit Ripple (Asynchronous) Counter

### 🔍 Description

A 4-bit ripple counter consists of 4 flip-flops connected in series, where the output of one flip-flop acts as the clock input for the next.
It’s called asynchronous because not all flip-flops are triggered simultaneously — the clock “ripples” through them.


### ⚙️ Working

The first FF toggles on every clock pulse.
Each subsequent FF toggles when the previous output goes from HIGH → LOW.



### 🧠 Truth Table
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


### ▶️ How to Run
1. Open Logisim → Load your circuit.
2. Set the clock input.
3. Observe Q0–Q3 on each clock pulse.
4. Q0 toggles fastest, Q3 slowest (divide-by-16 counter).
