;*-----------------------------------------------------------
* Title      : Real Time Embedded Systems Assignment
* Written by : Sachin Balappa Athani
* Date       : 16 Jan 2026
* Description: Complete runtime system with stopwatch and radiation monitor
*-----------------------------------------------------------

                                ;system call equates
sys     equ     0               ; system call trap (trap 0)
syscr   equ     1               ; create new task
sysdel  equ     2               ; delete task
syswtmx equ     3               ; wait on mutex
syssgmx equ     4               ; signal mutex
sysinmx equ     5               ; initialise mutex 
syswttm equ     6               ; wait on timer

usrcode equ     $1000           ;address of user task 0
usrstk  equ     $8000           ;address of user stack

ntcblst equ     8               ;number of records in tcb list

; TCB field offsets
tcbd0   equ     0               ; D register save
tcbd1   equ     4
tcbd2   equ     8
tcbd3   equ     12
tcbd4   equ     16
tcbd5   equ     20
tcbd6   equ     24
tcbd7   equ     28
tcba0   equ     32              ; A register save
tcba1   equ     36
tcba2   equ     40
tcba3   equ     44
tcba4   equ     48
tcba5   equ     52
tcba6   equ     56
tcba7   equ     60
tcbsr   equ     64              ; SR (status reg) save
tcbpc   equ     68              ; PC save
tcbnext equ     72              ; link to next record
tcbused equ     76              ; record in use flag
tcbwtim equ     80              ; timer wait expiry time
tcblen  equ     84              ; length of tcb record

;******************************************************************************
rts                                     ;RUNTIME SYSTEM
;******************************************************************************

;******************************************************************************
                                        ;INTERRUPT VECTORS
;******************************************************************************

        org     0
        
        dc.l    usrstk                  ; initial SP
        dc.l    res                     ; reset
        ds.b    $5C
        dc.l    fltint                  ; interrupt 1 (timer)
        ds.b    $18
        dc.l    flsint                  ; trap 0 (system call)
        
;*******************************************************************************        
res                                     ;RESET
;*******************************************************************************
        or      #$0700,sr               ; disable interrupts
        
        ; Initialize system variables
        move.l  #0,time
        move.l  #0,wttcb
        move.l  #0,mutex
        move.l  #0,sys_error
        
        ; Mark all TCBs as unused and clear links
        move.l  #ntcblst,d0
        lea     tcblst,a0
res_loop:
        move.l  #0,tcbused(a0)
        move.l  #0,tcbnext(a0)
        add.l   #tcblen,a0
        sub.l   #1,d0
        bne     res_loop
        
        ; Create TCB for task 0
        lea     tcblst,a0
        move.l  #1,tcbused(a0)          ; mark as used
        move.l  #usrcode,tcbpc(a0)      ; set PC
        move.l  #usrstk,tcba7(a0)       ; set SP
        move.l  #0,tcbsr(a0)            ; set SR
        
        ; Initialize all registers to 0
        move.l  #0,tcbd0(a0)
        move.l  #0,tcbd1(a0)
        move.l  #0,tcbd2(a0)
        move.l  #0,tcbd3(a0)
        move.l  #0,tcbd4(a0)
        move.l  #0,tcbd5(a0)
        move.l  #0,tcbd6(a0)
        move.l  #0,tcbd7(a0)
        move.l  #0,tcba0(a0)
        move.l  #0,tcba1(a0)
        move.l  #0,tcba2(a0)
        move.l  #0,tcba3(a0)
        move.l  #0,tcba4(a0)
        move.l  #0,tcba5(a0)
        move.l  #0,tcba6(a0)
        
        ; Make circular list with single element
        move.l  a0,tcbnext(a0)          ; points to itself
        move.l  a0,rdytcb               ; set ready list
        
        and     #$f8ff,sr               ; enable interrupts
        bra     disp                    ; start T0
        
;*******************************************************************************        
flih                                    ;FIRST-LEVEL INTERRUPT HANDLER
;*******************************************************************************

fltint                                  ;ENTRY FROM TIMER INTERRUPT  
        move.l  d0,d0sav                ;save D0
        move.l  #$0,d0                  ;set id = 0
        move.l  d0,id
        move.l  d0sav,d0                ;restore D0
        bra     fl1  

flsint                                  ;ENTRY FROM TRAP (SOFTWARE INTERRUPT)
        or      #$0700,sr               ;disable hardware interrupts
        move.l  d0,id                   ;store id
        bra     fl1
       
fl1     move.l  a0,a0sav                ;save working reg
        
        move.l  rdytcb,a0               ;A0 ^ 1st ready tcb (ie running tcb)
            
        move.l  d0,tcbd0(a0)            ;store registers
        move.l  d1,tcbd1(a0)       
        move.l  d2,tcbd2(a0)
        move.l  d3,tcbd3(a0) 
        move.l  d4,tcbd4(a0)
        move.l  d5,tcbd5(a0)       
        move.l  d6,tcbd6(a0)
        move.l  d7,tcbd7(a0)
        move.l  a0sav,d0 
        move.l  d0,tcba0(a0)
        move.l  a1,tcba1(a0)       
        move.l  a2,tcba2(a0)
        move.l  a3,tcba3(a0) 
        move.l  a4,tcba4(a0)
        move.l  a5,tcba5(a0)       
        move.l  a6,tcba6(a0)

        move    (sp),d0                 ;pop and store SR
        add.l   #2,sp              
        move.l  d0,tcbsr(a0)
        
        move.l  (sp),d0                 ;pop and store PC
        add.l   #4,sp
        move.l  d0,tcbpc(a0)
        
        move.l  a7,tcba7(a0)            ;store SP 
        
;******************************************************************************
serv                                    ;SERVICE ROUTINES
;******************************************************************************
        move.l  id,d0                   ; get function id
        
        cmp.l   #0,d0                   ; timer interrupt?
        beq     serv_timer
        
        cmp.l   #syscr,d0               ; create task?
        beq     serv_create
        
        cmp.l   #sysdel,d0              ; delete task?
        beq     serv_delete
        
        cmp.l   #syswttm,d0             ; wait timer?
        beq     serv_wait
        
        cmp.l   #sysinmx,d0             ; initialise mutex?
        beq     serv_init_mutex
        
        cmp.l   #syswtmx,d0             ; wait mutex?
        beq     serv_wait_mutex
        
        cmp.l   #syssgmx,d0             ; signal mutex?
        beq     serv_signal_mutex
        
        bra     sched                   ; unknown, go to scheduler

serv_timer:
        ; Increment system time
        move.l  time,d0
        add.l   #1,d0
        move.l  d0,time
        
        ; Process waiting tasks
        move.l  wttcb,a1                ; first waiting task
        move.l  #0,a2                   ; previous = null
        
st_loop:
        cmp.l   #0,a1                   ; any waiting tasks?
        beq     sched                   ; no, done
        
        move.l  tcbwtim(a1),d1          ; get wait value
        cmp.l   #$FFFFFFFF,d1           ; mutex wait?
        beq     st_next                 ; yes, skip (don't wake on timer)
        
        cmp.l   d0,d1                   ; time >= expiry?
        bgt     st_next                 ; no, check next
        
        ; Task expired - move to ready list
        move.l  tcbnext(a1),d2          ; save next waiting
        
        ; Remove from wait list
        cmp.l   #0,a2                   ; first in wait list?
        bne     st_not_first
        move.l  d2,wttcb                ; yes, update head
        bra     st_add
st_not_first:
        move.l  d2,tcbnext(a2)          ; no, link around it
        
st_add:
        ; Add to ready list after current
        move.l  rdytcb,a3
        move.l  tcbnext(a3),d3
        move.l  a1,tcbnext(a3)          ; current->next = expired
        move.l  d3,tcbnext(a1)          ; expired->next = old next
        
        ; Continue with saved next
        move.l  d2,a1
        move.l  #0,a2
        bra     st_loop
        
st_next:
        move.l  a1,a2                   ; previous = current
        move.l  tcbnext(a1),a1          ; current = next
        bra     st_loop

serv_create:
        ; D1 = task address, D2 = stack address
        ; Clear error flag first
        move.l  #0,sys_error
        
        move.l  #ntcblst,d0
        lea     tcblst,a1
        
sc_find:
        move.l  tcbused(a1),d3
        cmp.l   #0,d3
        beq     sc_found
        add.l   #tcblen,a1
        sub.l   #1,d0
        bne     sc_find
        
        ; No free TCB found - set error and return
        move.l  #1,sys_error            ; Error code 1: No TCB available
        bra     sched                   ; Continue without creating task
        
sc_found:
        ; Initialize TCB
        move.l  #1,tcbused(a1)
        
        ; Get parameters from calling task's saved registers
        move.l  rdytcb,a3               ; current task TCB
        move.l  tcbd1(a3),d3            ; get D1 (task address)
        move.l  d3,tcbpc(a1)            ; set PC
        move.l  tcbd2(a3),d3            ; get D2 (stack address)
        move.l  d3,tcba7(a1)            ; set SP
        move.l  #0,tcbsr(a1)
        
        ; Clear all registers
        move.l  #0,tcbd0(a1)
        move.l  #0,tcbd1(a1)
        move.l  #0,tcbd2(a1)
        move.l  #0,tcbd3(a1)
        move.l  #0,tcbd4(a1)
        move.l  #0,tcbd5(a1)
        move.l  #0,tcbd6(a1)
        move.l  #0,tcbd7(a1)
        move.l  #0,tcba0(a1)
        move.l  #0,tcba1(a1)
        move.l  #0,tcba2(a1)
        move.l  #0,tcba3(a1)
        move.l  #0,tcba4(a1)
        move.l  #0,tcba5(a1)
        move.l  #0,tcba6(a1)
        
        ; Add to ready list after current
        move.l  rdytcb,a3
        move.l  tcbnext(a3),d3
        move.l  a1,tcbnext(a3)
        move.l  d3,tcbnext(a1)
        
        bra     sched

serv_delete:
        ; Check if trying to delete T0 (first TCB)
        move.l  rdytcb,a1               ; current task
        lea     tcblst,a2               ; first TCB (T0)
        cmp.l   a1,a2                   ; is current task T0?
        beq     sd_error_t0             ; yes, cannot delete
        
        ; Mark TCB as unused
        move.l  #0,tcbused(a1)
        
        ; Remove from ready list
        ; Find previous TCB in circular list
        move.l  rdytcb,a2               ; start search
sd_find_prev:
        move.l  tcbnext(a2),a3
        cmp.l   a1,a3                   ; found current task?
        beq     sd_remove
        move.l  a3,a2
        bra     sd_find_prev
        
sd_remove:
        move.l  tcbnext(a1),a3          ; get next task
        move.l  a3,tcbnext(a2)          ; bypass deleted task
        move.l  a3,rdytcb               ; update ready pointer
        
        move.l  #0,sys_error            ; success
        bra     sched                   ; switch to next task
        
sd_error_t0:
        move.l  #2,sys_error            ; Error code 2: Cannot delete T0
        bra     sched                   ; continue running T0

serv_wait:
        ; Get D1 parameter from saved registers
        move.l  rdytcb,a0
        move.l  tcbd1(a0),d1            ; D1 = timer intervals to wait
        
        ; Validate wait time
        cmp.l   #0,d1                   ; check if wait time > 0
        ble     sw_invalid              ; invalid wait time
        
        ; Calculate expiry time
        move.l  time,d0
        add.l   d1,d0                   ; expiry = time + intervals
        
        move.l  rdytcb,a1               ; current task
        move.l  d0,tcbwtim(a1)          ; set expiry
        
        ; Save next ready task
        move.l  tcbnext(a1),a4          ; a4 = next ready
        
        ; Check if only task
        cmp.l   a1,a4
        beq     sw_error                ; can't wait if only task!
        
        ; Find task before current
        move.l  a4,a2                   ; start from next
sw_find:
        move.l  tcbnext(a2),a3
        cmp.l   a1,a3                   ; found current?
        beq     sw_remove
        move.l  a3,a2
        bra     sw_find
        
sw_remove:
        ; Remove from ready list
        move.l  a4,tcbnext(a2)          ; previous->next = next
        move.l  a4,rdytcb               ; new current = next
        
        ; Add to wait list
        move.l  wttcb,d3
        move.l  d3,tcbnext(a1)
        move.l  a1,wttcb
        
        move.l  #0,sys_error            ; success
        bra     sched
        
sw_error:
        ; Can't wait if only task - just continue
        move.l  #3,sys_error            ; Error code 3: Only task, cannot wait
        bra     sched
        
sw_invalid:
        ; Invalid wait time
        move.l  #4,sys_error            ; Error code 4: Invalid wait time
        bra     sched

serv_init_mutex:
        ; Get D1 parameter from saved registers
        move.l  rdytcb,a0
        move.l  tcbd1(a0),d1            ; D1 = initial value (0 or 1)
        move.l  d1,mutex
        bra     sched

serv_wait_mutex:
        ; Check if mutex is available
        move.l  mutex,d0
        cmp.l   #1,d0
        bne     swm_wait                ; mutex locked, wait
        
        ; Mutex available - lock it
        move.l  #0,mutex
        bra     sched                   ; continue running
        
swm_wait:
        ; Mutex not available - move task to wait list
        move.l  rdytcb,a1
        move.l  #$FFFFFFFF,tcbwtim(a1)  ; special marker for mutex wait
        
        ; Save next ready task
        move.l  tcbnext(a1),a4
        
        ; Check if only task
        cmp.l   a1,a4
        beq     swm_error               ; only task - error
        
        ; Find task before current
        move.l  a4,a2
swm_find:
        move.l  tcbnext(a2),a3
        cmp.l   a1,a3
        beq     swm_remove
        move.l  a3,a2
        bra     swm_find
        
swm_remove:
        ; Remove from ready list
        move.l  a4,tcbnext(a2)
        move.l  a4,rdytcb
        
        ; Add to wait list
        move.l  wttcb,d3
        move.l  d3,tcbnext(a1)
        move.l  a1,wttcb
        bra     sched
        
swm_error:
        bra     sched

serv_signal_mutex:
        ; Check if any task waiting on mutex
        move.l  wttcb,a1
        move.l  #0,a2
        
ssm_loop:
        cmp.l   #0,a1
        beq     ssm_no_waiter
        
        move.l  tcbwtim(a1),d0
        cmp.l   #$FFFFFFFF,d0           ; mutex waiter?
        beq     ssm_found
        
        move.l  a1,a2
        move.l  tcbnext(a1),a1
        bra     ssm_loop
        
ssm_found:
        ; Remove from wait list
        move.l  tcbnext(a1),d2
        cmp.l   #0,a2
        bne     ssm_not_first
        move.l  d2,wttcb
        bra     ssm_wake
        
ssm_not_first:
        move.l  d2,tcbnext(a2)
        
ssm_wake:
        ; Add to ready list
        move.l  rdytcb,a3
        move.l  tcbnext(a3),d3
        move.l  a1,tcbnext(a3)
        move.l  d3,tcbnext(a1)
        
        ; Mutex stays at 0 (locked for woken task)
        bra     sched
        
ssm_no_waiter:
        ; No waiter - unlock mutex
        move.l  #1,mutex
        bra     sched

;*******************************************************************************
sched                                   ;SCHEDULER  
;*******************************************************************************
        move.l  rdytcb,a0
        cmp.l   #0,a0                   ; safety check
        beq     sched                   ; spin if no ready tasks
        
        move.l  tcbnext(a0),a0          ; next task
        cmp.l   #0,a0                   ; safety check
        beq     sched                   ; spin if invalid
        
        move.l  a0,rdytcb               ; update ready pointer
        ; Fall through to dispatcher

;*******************************************************************************        
disp                                    ;DISPATCHER 
;*******************************************************************************
        move.l  rdytcb,a0               ;A0 ^ new running tcb
        cmp.l   #0,a0                   ; safety check
        beq     disp                    ; spin if invalid
        
        move.l  tcbd1(a0),d1            ;restore registers      
        move.l  tcbd2(a0),d2
        move.l  tcbd3(a0),d3 
        move.l  tcbd4(a0),d4
        move.l  tcbd5(a0),d5       
        move.l  tcbd6(a0),d6
        move.l  tcbd7(a0),d7
        move.l  tcba1(a0),a1       
        move.l  tcba2(a0),a2
        move.l  tcba3(a0),a3 
        move.l  tcba4(a0),a4
        move.l  tcba5(a0),a5       
        move.l  tcba6(a0),a6
        move.l  tcba7(a0),a7

        sub.l   #4,sp                   ;push PC
        move.l  tcbpc(a0),d0            
        move.l  d0,(sp)   

        sub.l   #2,sp           
        move.l  tcbsr(a0),d0            ;push SR
        move    d0,(sp)
        
        move.l  tcbd0(a0),d0            ;restore remaining registers
        move.l  tcba0(a0),a0
        
        rte                             ;return

;*******************************************************************************
                                        ;RTS variables
;*******************************************************************************

tcblst  ds.b    tcblen*ntcblst          ;tcb list
rdytcb  ds.l    1                       ;^ ready tcb list
wttcb   ds.l    1                       ;^ waiting tcb
a0sav   ds.l    1                       ;A0 temporary save
d0sav   ds.l    1                       ;D0 temporary save
id      ds.l    1                       ;function id
time    ds.l    1                       ;system time
mutex   ds.l    1                       ;mutex variable
sys_error ds.l  1                       ;system error flag

;*******************************************************************************
;USER APPLICATION TASKS
;*******************************************************************************

        org     usrcode
        bra     prog1
;        bra     prog2

;*******************************************************************************
; PROGRAM 1 - STOPWATCH
;*******************************************************************************

prog1:

; Hardware addresses
p1_sevseg  equ     $e0000e         ; rightmost 7-segment display
p1_sw      equ     $e00014         ; switch/button

;-------------------------------------------------------------------------------
; TASK 0 - Display stopwatch
;-------------------------------------------------------------------------------
p1_t0:
        ; Initialize variables
        move.l  #0,p1_count             ; count = 0
        move.l  #0,p1_running           ; running = 0
        
        ; Blank all displays
        move.b  #0,$e00000              ; digit 0 (leftmost)
        move.b  #0,$e00002              ; digit 1
        move.b  #0,$e00004              ; digit 2
        move.b  #0,$e00006              ; digit 3
        move.b  #0,$e00008              ; digit 4
        move.b  #0,$e0000a              ; digit 5
        move.b  #0,$e0000c              ; digit 6
        move.b  #0,$e0000e              ; digit 7 (rightmost)
        
        ; Display initial "00"
        move.b  #$3f,$e0000e            ; 0 on rightmost digit
        move.b  #0,$e0000c              ; blank tens digit
        
        ; Start task 1 (button monitor)
        move.l  #syscr,d0               ; create task
        move.l  #p1_t1,d1               ; address of task 1
        move.l  #$4000,d2               ; top of stack for task 1
        trap    #sys
        
        move.l  sys_error,d0
        cmp.l   #0,d0
        bne     p1_task_failed          ; handle error
        
        ; Main loop
p1_t0_loop:
        ; Display current count
        move.l  p1_count,d0
        bsr     p1_display
        
        ; Check if running
        move.l  p1_running,d0
        cmp.l   #0,d0
        beq     p1_t0_loop              ; if not running, just loop
        
        ; Running - increment count
        move.l  p1_count,d0
        add.l   #1,d0
        cmp.l   #100,d0                 ; check if >= 100
        blt     p1_t0_no_wrap
        move.l  #0,d0                   ; wrap to 0
         
p1_t0_no_wrap:
        move.l  d0,p1_count
        
        ; Wait for 10 timer intervals (1 second)
        move.l  #syswttm,d0
        move.l  #10,d1
        trap    #sys
        
        bra     p1_t0_loop
        
p1_task_failed:
        ; Flash all LEDs to indicate error
        move.b  #$FF,$e00010
        ; Continue anyway (degraded mode)
        bra     p1_t0_loop
        
;-------------------------------------------------------------------------------
; Display subroutine - displays count on 7-segment display (2 digits)
;-------------------------------------------------------------------------------
p1_display:
        ; D0 contains count value
        
        ; Extract tens digit
        move.l  d0,d1
        divu    #10,d1                  ; d1 = count / 10
        and.l   #$FFFF,d1               ; keep only quotient (tens)
        
        ; Extract ones digit  
        move.l  d0,d2
        divu    #10,d2
        swap    d2                      ; get remainder
        and.l   #$FFFF,d2               ; d2 = ones digit
        
        ; Convert ones to segment pattern
        move.l  #p1_kseg,a0
        move.l  d2,d4
        move.b  (a0,d4.l),d4            ; d4 = ones pattern
        
        ; Convert tens to segment pattern (or blank if zero)
        cmp.l   #0,d1
        beq     p1_display_blank_tens
        
        move.l  #p1_kseg,a0
        move.l  d1,d3
        move.b  (a0,d3.l),d3            ; d3 = tens pattern
        bra     p1_display_output
        
p1_display_blank_tens:
        move.b  #0,d3                   ; blank tens digit
        
p1_display_output:
        ; Output ones digit to rightmost display
        move.b  d4,p1_sevseg            ; ones digit at E0000E
        
        ; Output tens digit to next display (digit 6)
        move.b  d3,$e0000c              ; tens digit at E0000C
        
        rts

;-------------------------------------------------------------------------------
; 7-segment lookup table
;-------------------------------------------------------------------------------
p1_kseg:
        dc.b    $3f                     ; 0
        dc.b    $06                     ; 1
        dc.b    $5b                     ; 2
        dc.b    $4f                     ; 3
        dc.b    $66                     ; 4
        dc.b    $6d                     ; 5
        dc.b    $7d                     ; 6
        dc.b    $07                     ; 7
        dc.b    $7f                     ; 8
        dc.b    $67                     ; 9
        dc.b    $77                     ; A
        dc.b    $7c                     ; b
        dc.b    $39                     ; C
        dc.b    $5e                     ; d
        dc.b    $79                     ; E
        dc.b    $71                     ; F

;-------------------------------------------------------------------------------
; TASK 1 - Button monitor
;-------------------------------------------------------------------------------
p1_t1:
        move.l  #1,p1_btn_prev          ; previous button state = 1 (released)
        
p1_t1_loop:
        ; Read button 0
        move.b  p1_sw,d0                ; read switches
        and.l   #$01,d0                 ; isolate button 0
        
        ; Check for state change
        move.l  p1_btn_prev,d1
        cmp.l   d0,d1                   ; same as before?
        beq     p1_t1_loop              ; yes, keep checking
        
        ; State changed
        move.l  d0,p1_btn_prev          ; save new state
        
        ; Check if it's a press (going to 0)
        cmp.l   #0,d0
        bne     p1_t1_loop              ; released, ignore
        
        ; Button pressed - toggle running
        move.l  p1_running,d2
        eor.l   #1,d2                   ; toggle
        move.l  d2,p1_running
        
        bra     p1_t1_loop

;-------------------------------------------------------------------------------
; Program 1 Variables
;-------------------------------------------------------------------------------
p1_count:       ds.l    1               ; stopwatch count (0-99)
p1_running:     ds.l    1               ; running flag (0 or 1)
p1_btn_prev:    ds.l    1               ; previous button state

;*******************************************************************************
; PROGRAM 2 - RADIATION MONITOR (FIXED LED HANDLING)
;*******************************************************************************

prog2:

; Hardware addresses
p2_led     equ     $e00010         ; LEDs
p2_sevseg  equ     $e0000e         ; 7-segment display

; Critical value threshold
p2_crit_val equ    $100000         ;

;-------------------------------------------------------------------------------
; TASK 0 - Update counter a and c
;-------------------------------------------------------------------------------
p2_t0:
        ; Initialize mutex to 0 (locked initially)
        move.l  #sysinmx,d0
        move.l  #0,d1
        trap    #sys
        
        ; Initialize variables
        move.l  #0,p2_a_var
        move.l  #0,p2_b_var
        move.l  #0,p2_c_var
        move.l  #0,p2_danger_flag       ; danger flag
        
        ; Clear LEDs
        move.b  #0,p2_led
        
        ; Set mutex to 1 (unlocked) so tasks can use it
        move.l  #sysinmx,d0
        move.l  #1,d1
        trap    #sys
        
        ; Start task 1 (counter b updater)
        move.l  #syscr,d0
        move.l  #p2_t1,d1               ; address of task 1
        move.l  #$4000,d2               ; top of stack
        trap    #sys
        
        ; Start task 2 (monitor/display)
        move.l  #syscr,d0
        move.l  #p2_t2,d1               ; address of task 2
        move.l  #$5000,d2               ; top of stack
        trap    #sys
        
        ; Main loop - continuously update a and c
p2_t0_loop:
        ; Update counter a (not shared, no mutex needed)
        move.l  p2_a_var,d0
        add.l   #1,d0
        move.l  d0,p2_a_var
        
        ; Wait for mutex before updating c (critical section)
        move.l  #syswtmx,d0
        trap    #sys
        
        ; Update shared counter c
        move.l  p2_c_var,d0
        add.l   #1,d0
        move.l  d0,p2_c_var
        
        ; Signal mutex (end critical section)
        move.l  #syssgmx,d0
        trap    #sys
        
        ; Check if c exceeds critical value
        move.l  p2_c_var,d0
        cmp.l   #p2_crit_val,d0
        ble     p2_t0_no_danger
        
        ; Set danger flag (shared variable approach)
        move.l  #1,p2_danger_flag
        
p2_t0_no_danger:
        bra     p2_t0_loop

;-------------------------------------------------------------------------------
; TASK 1 - Update counter b and c
;-------------------------------------------------------------------------------
p2_t1:
        ; Main loop - continuously update b and c
p2_t1_loop:
        ; Update counter b (not shared, no mutex needed)
        move.l  p2_b_var,d0
        add.l   #1,d0
        move.l  d0,p2_b_var
        
        ; Wait for mutex before updating c (critical section)
        move.l  #syswtmx,d0
        trap    #sys
        
        ; Update shared counter c
        move.l  p2_c_var,d0
        add.l   #1,d0
        move.l  d0,p2_c_var
        
        ; Signal mutex (end critical section)
        move.l  #syssgmx,d0
        trap    #sys
        
        ; Check if c exceeds critical value
        move.l  p2_c_var,d0
        cmp.l   #p2_crit_val,d0
        ble     p2_t1_no_danger
        
        ; Set danger flag (shared variable approach)
        move.l  #1,p2_danger_flag
        
p2_t1_no_danger:
        bra     p2_t1_loop

;-------------------------------------------------------------------------------
; TASK 2 - Monitor and display results every 8 seconds
;-------------------------------------------------------------------------------
p2_t2:
        ; Main loop - repeat every 8 seconds
p2_t2_loop:
        ; Wait for 8 seconds (80 timer intervals at 100ms each)
        move.l  #syswttm,d0
        move.l  #80,d1
        trap    #sys
        
        ; Store a, b, c values in memory for inspection
        move.l  p2_a_var,$2000
        move.l  p2_b_var,$2004
        move.l  p2_c_var,$2008
        
        ; Calculate c / 8 (shift right by 3 bits)
        move.l  p2_c_var,d0
        lsr.l   #3,d0                   ; divide by 8 using shift
        
        ; Display result on 7-segment (hexadecimal)
        bsr     p2_display_hex
        
        ; Build LED output byte based on flags
        move.b  #0,d2                   ; start with all LEDs off
        
        ; Check danger flag and set RH LED (bit 0)
        move.l  p2_danger_flag,d0
        cmp.l   #0,d0
        beq     p2_t2_no_danger_led
        or.b    #$01,d2                 ; set RH LED
        
p2_t2_no_danger_led:
        ; Check for mutex errors: if a + b - c > 2, set LH LED
        move.l  p2_a_var,d0
        add.l   p2_b_var,d0             ; d0 = a + b
;       add.l   #3,d0                   ; To test LH LED
        move.l  p2_c_var,d1
        sub.l   d1,d0                   ; d0 = a + b - c
        
        cmp.l   #2,d0
        ble     p2_t2_no_error_led
        or.b    #$80,d2                 ; set LH LED (bit 7)
        
p2_t2_no_error_led:
        ; Write final LED value once
        move.b  d2,p2_led
        
        ; Repeat for next 8-second interval
        bra     p2_t2_loop

;-------------------------------------------------------------------------------
; Display hexadecimal value on 7-segment display
; Input: D0 = value to display (shows rightmost 4 hex digits on 4 displays)
;-------------------------------------------------------------------------------
p2_display_hex:
        ; Save registers
        move.l  d1,-(sp)
        move.l  d2,-(sp)
        move.l  d3,-(sp)
        move.l  d4,-(sp)
        move.l  d5,-(sp)
        move.l  a0,-(sp)
        
        ; Extract 4 nibbles (rightmost 4 hex digits)
        move.l  d0,$2010
        move.l  d0,d2
        and.l   #$0F,d2                 ; d2 = digit 0
        
        move.l  d0,d3
        lsr.l   #4,d3
        and.l   #$0F,d3                 ; d3 = digit 1
        
        move.l  d0,d4
        lsr.l   #8,d4
        and.l   #$0F,d4                 ; d4 = digit 2
        
        move.l  d0,d5
        lsr.l   #8,d5
        lsr.l   #4,d5
        and.l   #$0F,d5                 ; d5 = digit 3
        
        ; Convert to segment patterns
        move.l  #p2_hex_table,a0
        
        move.b  (a0,d2.l),d2            ; digit 0 pattern
        move.b  (a0,d3.l),d3            ; digit 1 pattern
        move.b  (a0,d4.l),d4            ; digit 2 pattern
        move.b  (a0,d5.l),d5            ; digit 3 pattern
        
        ; Output to 7-segment displays
        move.b  d2,$e0000e              ; digit 0 (rightmost)
        move.b  d3,$e0000c              ; digit 1
        move.b  d4,$e0000a              ; digit 2
        move.b  d5,$e00008              ; digit 3
        move.b  #0,$e00006              ; digit 4 blank
        move.b  #0,$e00004              ; digit 5 blank
        move.b  #0,$e00002              ; digit 6 blank
        move.b  #0,$e00000              ; digit 7 blank
        
        ; Restore registers
        move.l  (sp)+,a0
        move.l  (sp)+,d5
        move.l  (sp)+,d4
        move.l  (sp)+,d3
        move.l  (sp)+,d2
        move.l  (sp)+,d1
        
        rts

;-------------------------------------------------------------------------------
; Hexadecimal 7-segment lookup table (0-F)
;-------------------------------------------------------------------------------
p2_hex_table:
        dc.b    $3f                     ; 0
        dc.b    $06                     ; 1
        dc.b    $5b                     ; 2
        dc.b    $4f                     ; 3
        dc.b    $66                     ; 4
        dc.b    $6d                     ; 5
        dc.b    $7d                     ; 6
        dc.b    $07                     ; 7
        dc.b    $7f                     ; 8
        dc.b    $67                     ; 9
        dc.b    $77                     ; A
        dc.b    $7c                     ; b
        dc.b    $39                     ; C
        dc.b    $5e                     ; d
        dc.b    $79                     ; E
        dc.b    $71                     ; F

;-------------------------------------------------------------------------------
; Program 2 Variables
;-------------------------------------------------------------------------------

                org     $2020
p2_a_var:       ds.l    1               ; counter a
p2_b_var:       ds.l    1               ; counter b  
p2_c_var:       ds.l    1               ; counter c (shared, protected by mutex)
p2_danger_flag: ds.l    1               ; danger condition flag

        END     res

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
