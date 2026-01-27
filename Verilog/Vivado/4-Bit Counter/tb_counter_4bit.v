`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.01.2026 13:41:52
// Design Name: 
// Module Name: tb_counter_4bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_counter_4bit;

// ============================================================================
// 1. SIGNAL DECLARATIONS
// ============================================================================
reg clk;
reg rst;
reg enable;
reg load;
reg [3:0] load_value;
wire [3:0] count;
wire terminal_count;

integer pass_count = 0;
integer fail_count = 0;

// ============================================================================
// 2. DUT INSTANTIATION
// ============================================================================
counter_4bit DUT (
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .load(load),
    .load_value(load_value),
    .count(count),
    .terminal_count(terminal_count)
);

// ============================================================================
// 3. CLOCK GENERATION (10ns period = 100MHz)
// ============================================================================
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// ============================================================================
// 4. TEST STIMULUS
// ============================================================================
initial begin
    // Initialize signals
    rst = 1;
    enable = 0;
    load = 0;
    load_value = 4'b0000;
    
    $display("========================================");
    $display("  4-BIT COUNTER TESTBENCH");
    $display("========================================");
    
    // TEST 1: Reset functionality
    $display("\n[TEST 1] Reset Test");
    #20 rst = 0;
    #10;
    if (count == 4'b0000) begin
        $display("PASS: Counter reset to 0");
        pass_count = pass_count + 1;
    end else begin
        $display("FAIL: Counter = %b, expected 0000", count);
        fail_count = fail_count + 1;
    end
    
    // TEST 2: Enable counting
    $display("\n[TEST 2] Enable Counting (0→5)");
    enable = 1;
    repeat(5) @(posedge clk);
    #1;
    if (count == 4'b0101) begin
        $display("PASS: Counter reached 5");
        pass_count = pass_count + 1;
    end else begin
        $display("FAIL: Counter = %d, expected 5", count);
        fail_count = fail_count + 1;
    end
    
    // TEST 3: Disable (count should hold)
    $display("\n[TEST 3] Disable Test");
    enable = 0;
    repeat(3) @(posedge clk);
    #1;
    if (count == 4'b0101) begin
        $display("PASS: Counter held at 5");
        pass_count = pass_count + 1;
    end else begin
        $display("FAIL: Counter changed to %d", count);
        fail_count = fail_count + 1;
    end
    
    // TEST 4: Load value
    $display("\n[TEST 4] Load Value = 12");
    load = 1;
    load_value = 4'b1100;
    @(posedge clk);
    #1 load = 0;
    if (count == 4'b1100) begin
        $display("PASS: Counter loaded with 12");
        pass_count = pass_count + 1;
    end else begin
        $display("FAIL: Counter = %d, expected 12", count);
        fail_count = fail_count + 1;
    end
    
    // TEST 5: Count to terminal (15)
    $display("\n[TEST 5] Terminal Count");
    enable = 1;
    wait(terminal_count == 1);
    #1;
    if (count == 4'b1111 && terminal_count == 1) begin
        $display("PASS: Terminal count reached");
        pass_count = pass_count + 1;
    end else begin
        $display("FAIL: Terminal count not detected");
        fail_count = fail_count + 1;
    end
    
    // TEST 6: Rollover to 0
    $display("\n[TEST 6] Rollover Test");
    @(posedge clk);
    #1;
    if (count == 4'b0000) begin
        $display("PASS: Counter rolled over to 0");
        pass_count = pass_count + 1;
    end else begin
        $display("FAIL: Counter = %d after rollover", count);
        fail_count = fail_count + 1;
    end
    
    // TEST 7: Reset during counting
    $display("\n[TEST 7] Reset During Operation");
    enable = 1;
    repeat(5) @(posedge clk);
    rst = 1;
    @(posedge clk);
    #1 rst = 0;
    if (count == 4'b0000) begin
        $display("PASS: Reset works during counting");
        pass_count = pass_count + 1;
    end else begin
        $display("FAIL: Reset failed");
        fail_count = fail_count + 1;
    end
    
    // FINAL SUMMARY
    #50;
    $display("\n========================================");
    $display("  TEST SUMMARY");
    $display("========================================");
    $display("  Total Tests: %0d", pass_count + fail_count);
    $display("  Passed:      %0d", pass_count);
    $display("  Failed:      %0d", fail_count);
    if (fail_count == 0)
        $display("  STATUS: ALL TESTS PASSED");
    else
        $display("  STATUS:SOME TESTS FAILED");
    $display("========================================\n");
    
    $finish;
end

// ============================================================================
// 5. WAVEFORM MONITORING
// ============================================================================
initial begin
    $monitor("Time=%0t | RST=%b | EN=%b | LOAD=%b | Count=%d (%b) | TC=%b", 
             $time, rst, enable, load, count, count, terminal_count);
end

// ============================================================================
// 6. TIMEOUT PROTECTION
// ============================================================================
initial begin
    #5000;
    $display("\n ERROR: Simulation timeout!");
    $finish;
end

initial begin
    $dumpfile("counter_4bit.vcd");
    $dumpvars(0, tb_counter_4bit);
end

endmodule
