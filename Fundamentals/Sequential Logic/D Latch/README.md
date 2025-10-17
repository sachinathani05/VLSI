# 🧩 D Latch
## 🔍 Description

Level-triggered version of D FF.
When Enable = 1, output follows input D;
When Enable = 0, output holds last state.

## 🧠 Truth Table
| EN | D | Q(next) |
| -- | - | ------- |
| 0  | X | Q(prev) |
| 1  | 0 | 0       |
| 1  | 1 | 1       |

## ▶️ How to Run
1. Connect D and Enable.
2. While Enable = 1, change D → Q follows immediately.
3. Disable → Q holds last state.
