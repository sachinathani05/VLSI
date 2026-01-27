# 4-Bit ALU (Vivado)

## 📘 Description
This project implements a **4-bit Arithmetic Logic Unit (ALU)** capable of performing multiple operations based on a select input.

Supported operations:
- Addition
- Subtraction
- AND
- OR
- XOR

---

## 🧠 Design Concept
- **Type:** Combinational Logic
- **Operation Selection:** `case` statement
- **Carry Handling:** Extended internal register
- **Zero Flag:** Indicates result equals zero

---

## 📥 Inputs & 📤 Outputs

| Signal | Width | Description |
|------|------|------------|
| a | 4 | Operand A |
| b | 4 | Operand B |
| op | 3 | Operation select |
| result | 4 | ALU output |
| carry | 1 | Carry/borrow flag |
| zero | 1 | Zero detection flag |

---

## 🔢 Operation Table

| op | Operation |
|----|----------|
| 000 | ADD |
| 001 | SUB |
| 010 | AND |
| 011 | OR |
| 100 | XOR |

---

## 🧪 Vivado Simulation Steps

### 1️⃣ Add Design Sources
- `alu_4bit.v`

### 2️⃣ Add Simulation Source
- `tb_alu_4bit.v`

### 3️⃣ Run Behavioral Simulation

Run Simulation → Run Behavioral Simulation

---

## 📊 What to Verify
- Correct arithmetic results
- Carry flag behavior
- Zero flag assertion
- No latch inference

---

## 🧩 Key Learnings
- Combinational logic design
- Case statements
- Flag generation (zero, carry)
- Testbench-driven verification

---

## 🛠 Tool Used
- **Vivado XSIM**
