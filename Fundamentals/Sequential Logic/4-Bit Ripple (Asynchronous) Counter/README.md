🧮 4-Bit Ripple (Asynchronous) Counter

🔹 Description

A ripple counter (asynchronous counter) is built using T flip-flops or JK flip-flops in toggle mode.
The output of one flip-flop acts as the clock input for the next, so the bits “ripple” through — each stage toggles when the previous one changes from 1 → 0.


🔹 Truth Table
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
| …            | …  | …  | …  | …  |
