# EEE8087 — Real-Time Operating System (RTOS) in M68K Assembly

> **Academic Project** — EEE8087 Real Time Embedded Systems  
> Submitted: January 2026

---

## Overview

This project implements a **time-slicing Real-Time Operating System (RTOS)** written entirely in Motorola 68000 (M68K) assembly language. The system manages multiple concurrent user tasks on a single processor by rapidly switching between them, creating the illusion of parallel execution. It was developed and tested on the **EASy68K simulator**.

The RTOS is built from scratch and includes a first-level interrupt handler (FLIH), a round-robin scheduler, a context dispatcher, and a set of six system calls accessible via software interrupts. Two application programs — a **stopwatch** and a **radiation monitor** — are included to demonstrate the system in action.

---

## Concepts & Key Ideas

### What is Time-Slicing?

Time-slicing is a CPU scheduling technique where the processor's time is divided into small fixed intervals (slices). Each task gets one slice before the scheduler moves on to the next. Because switching is fast (microseconds), all tasks appear to run simultaneously — a concept called **multitasking**.

In this system, a hardware timer fires every **100 ms**, triggering the FLIH. At that point, the current task is paused, its state is saved, and the scheduler picks the next task to resume.

### What is a Task Control Block (TCB)?

A TCB is a data structure that stores the complete state of a task so it can be paused and resumed exactly where it left off. Each TCB holds:

- Saved values of all 16 M68K registers (D0–D7, A0–A7)
- The Program Counter (PC) — where execution was interrupted
- The Status Register (SR) — processor flags at time of interruption
- A `next` pointer — linking TCBs into circular (ready) or linear (waiting) lists
- A `used` flag — whether this TCB slot is occupied
- A `wait_time` field — expiry tick for timed waits, or `0xFFFFFFFF` for mutex waits

The system maintains **8 TCB slots** in a statically allocated list.

### Task States

At any moment, each task is in one of three states:

```
RUNNING ──(timer/syscall)──► READY ◄──(timer/signal)── WAITING
                               │                            ▲
                               └────(wait_time/mutex)───────┘
```

- **Running** — the currently executing task (always `rdytcb` head)
- **Ready** — in the circular `rdytcb` list, waiting for its turn
- **Waiting** — in the linear `wttcb` list, blocked on a timer or mutex

### Round-Robin Scheduling

The scheduler simply follows the `next` pointer in the circular ready list. Every task gets an equal share of CPU time — no priorities, no starvation.

### Software Interrupts (Traps)

System calls are made via the M68K `trap #0` instruction. This works like a hardware interrupt: the processor saves the PC and SR, then jumps to the software ISR entry point (`flsint`). Hardware interrupts are immediately masked (priority set to 7) to keep the OS uninterruptible during a system call.

The calling convention is:
```
D0 = function ID (1–6)
D1, D2 = parameters (function-dependent)
```

### The Stack and Context Switching

The M68K stack grows downward. When an interrupt occurs, the processor automatically pushes the PC (4 bytes) and SR (2 bytes). The FLIH then manually saves all other registers into the TCB. The dispatcher reverses this — it loads the TCB's saved registers, manually pushes the saved PC and SR onto the stack, then uses `RTE` (Return from Exception) to atomically restore them and resume the task.

### Critical Sections and Race Conditions

When multiple tasks read-modify-write the same variable, a **race condition** can corrupt data. For example, if Task A reads `c`, gets interrupted, Task B increments `c`, and then Task A writes its (now stale) value back — one increment is lost.

The mutex prevents this. Only one task can hold the mutex at a time; others block until it is signalled.

---

## System Architecture

```
 ┌──────────────────────────────────────────────────┐
 │                  User Tasks                       │
 │    T0 (default) │ T1 │ T2 │ ... │ T7             │
 └──────────────┬───────────────────────────────────┘
                │  trap #0 (system call)
 ┌──────────────▼───────────────────────────────────┐
 │     First-Level Interrupt Handler (FLIH)          │
 │  ┌─────────┐  ┌──────────────────────────────┐   │
 │  │ fltint  │  │          flsint              │   │
 │  │ (timer) │  │  (software interrupt / trap) │   │
 │  └────┬────┘  └──────────────┬───────────────┘   │
 │       └──────────┬───────────┘                   │
 │             ┌────▼──────┐                        │
 │             │  Save all │  (registers → TCB)     │
 │             │ registers │                        │
 │             └────┬──────┘                        │
 │   ┌──────────────▼──────────────────────────┐    │
 │   │           Service Routines               │    │
 │   │  timer │ create │ delete │ wait_time     │    │
 │   │  wait_mutex │ signal_mutex │ init_mutex  │    │
 │   └──────────────┬──────────────────────────┘    │
 │             ┌────▼──────┐                        │
 │             │ Scheduler │  (advance rdytcb ptr)  │
 │             └────┬──────┘                        │
 │             ┌────▼──────┐                        │
 │             │Dispatcher │  (restore regs + RTE)  │
 │             └───────────┘                        │
 └──────────────────────────────────────────────────┘
```

---

## Memory Layout

```
Address     Contents
────────────────────────────────
0x0000      Interrupt vector table
0x0064      Timer interrupt vector (→ fltint)
0x0080      Trap 0 vector (→ flsint)

[RTOS code and data]
  tcblst    8 × 84-byte TCB records
  rdytcb    Pointer to head of ready list
  wttcb     Pointer to head of waiting list
  mutex     Global mutex variable (0=locked, 1=unlocked)
  time      System tick counter
  sys_error Last system call error code

0x1000      User task T0 entry (usrcode)
0x4000      Stack top for T1
0x5000      Stack top for T2
0x8000      Stack top for T0 (usrstk)
0x2020+     Program 2 shared variables (a, b, c, danger_flag)
```

Each task has its own stack region. Stacks grow **downward**. Overlapping stack regions will cause unpredictable corruption — allocate at least 1 KB per task.

---

## System Call API

All calls use `trap #0`. Load the function ID into `D0` and parameters into `D1`, `D2`.

| ID | Name | Parameters | Description |
|----|------|------------|-------------|
| 1 | **Create Task** | D1=code addr, D2=stack top | Creates a new task and adds it to the ready list. Fails silently if all 8 TCB slots are occupied. |
| 2 | **Delete Task** | — | Terminates the calling task. T0 cannot be deleted. |
| 3 | **Wait Mutex** | — | Acquires the mutex. Blocks the task if the mutex is locked. |
| 4 | **Signal Mutex** | — | Releases the mutex. Wakes the first blocked task if any. |
| 5 | **Init Mutex** | D1=0 or 1 | Sets the mutex to locked (0) or unlocked (1). Does not wake waiting tasks. |
| 6 | **Wait Time** | D1=tick count | Suspends the task for N × 100 ms timer ticks. |

### Example: Creating a Task

```asm
move.l  #1,d0       ; function ID: create task
move.l  #my_task,d1 ; start address of new task
move.l  #$4000,d2   ; top of stack
trap    #0          ; invoke RTOS
```

### Example: Protecting a Shared Variable

```asm
move.l  #3,d0       ; wait mutex
trap    #0

; --- critical section ---
move.l  shared_var,d0
add.l   #1,d0
move.l  d0,shared_var
; --- end critical section ---

move.l  #4,d0       ; signal mutex
trap    #0
```

---

## Error Codes

The system writes to the `sys_error` variable after each service call.

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | No free TCB — task not created |
| 2 | Attempted to delete T0 — ignored |
| 3 | Only task in system — wait skipped to prevent deadlock |
| 4 | Invalid wait time (≤ 0) |

---

## Application Programs

Both programs are included in the same source file. To switch between them, comment/uncomment the branch at `org usrcode`:

```asm
org usrcode
bra prog1   ; run stopwatch
; bra prog2 ; run radiation monitor
```

### Program 1 — Stopwatch

Demonstrates task creation, concurrent execution, and timer-based delays.

- **T0** (display task): Shows a 2-digit count on the 7-segment display. When the `running` flag is set, it increments the count every second (10 × 100 ms using `Wait Time`) and wraps at 99.
- **T1** (button task): Polls pushbutton 0. Each press toggles the shared `running` flag.
- The shared flag does **not** need mutex protection here — only T1 writes it, only T0 reads it, so no read-modify-write conflict exists.

### Program 2 — Radiation Monitor

Demonstrates mutex protection of a shared counter updated by two concurrent tasks.

- **T0** and **T1** (counter tasks): Continuously increment their own private counters (`a` and `b`) and a shared counter (`c`), using mutex wait/signal around every update to `c`.
- **T2** (monitor task): Waits 80 ticks (8 seconds), then reads all counters, displays `c / 8` in hex on the 7-segment display, lights the **RH LED** if `c` exceeded the critical threshold, and lights the **LH LED** if `a + b − c > 2` (indicating a mutex error / lost update).

---

## How to Run

1. Open **EASy68K** (the M68K simulator).
2. Load `Real_Time_Embedded_Systems_Assignment_Final_Code.X68`.
3. Assemble the file (`Assemble` → `Assemble`).
4. In the hardware panel, set **Interrupt 1** to fire automatically at **100 ms** intervals.
5. Set the initial simulation speed to a comfortable rate.
6. Click **Run**.

To switch programs, edit the branch at `org usrcode` as shown above, then re-assemble.

---

## Key Concepts for Interview / Portfolio

If you are using this project to demonstrate your skills, here are the core concepts it covers and the kinds of questions you might be asked:

**Context Switching**
> *Q: How does the RTOS save and restore a task's state?*  
> The FLIH saves all 16 registers into the task's TCB. The dispatcher reads them back and manually reconstructs the stack frame (pushing saved PC and SR) before executing `RTE`, which atomically restores PC and SR to resume the task.

**Circular vs Linear Lists**
> *Q: Why is the ready list circular but the waiting list linear?*  
> The scheduler needs to cycle through ready tasks in rotation, so a circular list lets it always follow `next` without special end-of-list handling. The waiting list only needs to be searched and spliced; no rotation is needed.

**Mutual Exclusion**
> *Q: When is a mutex necessary?*  
> Only when a variable is modified by multiple tasks through a read-modify-write sequence. A variable written by only one task (even if read by many) does not need mutex protection because the write is atomic at the assembly instruction level.

**Deadlock Prevention**
> *Q: What happens if the only task in the system calls Wait Time or Wait Mutex?*  
> The RTOS detects this case (`rdytcb->next == rdytcb`) and skips the wait, setting error code 3, to prevent the system from locking up permanently.

**Interrupt Priority**
> *Q: Why must hardware interrupts be disabled at the start of a software ISR?*  
> Software interrupts run at priority 0, so a hardware interrupt at level 1–7 could preempt the RTOS mid-operation, corrupting its internal state. Setting the SR mask to 7 immediately on trap entry prevents this.

**Stack Discipline**
> *Q: Why must each task have its own stack?*  
> The stack holds the task's return addresses, local variables, and the saved PC/SR from interrupt entry. If tasks shared a stack, one task's interrupt handler would overwrite another task's saved return address, crashing both.

---

## Project Structure

```
.
├── Real_Time_Embedded_Systems_Assignment_Final_Code.X68   ← Main source
└── Real_Time_Embedded_Systems_-_EEE8087.pdf   ← User manual
```

---

## Acknowledgements

Developed as coursework for **EEE8087 Real Time Embedded Systems**.  
The FLIH structure and TCB layout were based on the demonstration system provided in the module notes. All service routines, the scheduler, the dispatcher, and the two application programs were written.
