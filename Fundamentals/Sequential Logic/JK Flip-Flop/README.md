🔹 Description

A versatile flip-flop with two inputs J and K.
It combines the behavior of SR, D, and T flip-flops.
When J=K=1, it toggles output.

🔹 Truth Table
| J | K | CLK | Q(next)  |
| - | - | --- | -------- |
| 0 | 0 | ↑   | Q(prev)  |
| 0 | 1 | ↑   | 0        |
| 1 | 0 | ↑   | 1        |
| 1 | 1 | ↑   | ¬Q(prev) |
