🔹 Description

A level-triggered device that passes input D → Q when Enable (EN) is HIGH.
When EN = 0, the output holds the last value.

🔹 Truth Table
| EN | D | Q(next) |
| -- | - | ------- |
| 0  | X | Q(prev) |
| 1  | 0 | 0       |
| 1  | 1 | 1       |
