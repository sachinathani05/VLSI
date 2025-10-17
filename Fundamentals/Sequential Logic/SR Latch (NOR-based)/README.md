🔹 Description

Basic bistable circuit formed using NOR gates.
Has two inputs — S (Set) and R (Reset).
Used for simple memory storage.

🔹 Truth Table
| S | R | Q(next) | Q̅(next) |
| - | - | ------- | -------- |
| 0 | 0 | Q(prev) | Q̅(prev) |
| 0 | 1 | 0       | 1        |
| 1 | 0 | 1       | 0        |
| 1 | 1 | Invalid | Invalid  |
