`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: testing_tb
// Project    : Power-Efficient Built-In Self-Repair (BISR) for Interleaved Memory
// Description: Testbench for testing_bisr. Runs BIST, then writes 0x11..0xFF to
//              addresses 0x1..0xE and reads them back. Faulty addresses 0x7 and
//              0xE are rerouted to redundant memory.
//////////////////////////////////////////////////////////////////////////////////
module testing_tb();
    // Inputs
    reg clk;
    reg reset;
    reg [3:0] addr;
    reg [7:0] data_in;
    reg rw;             // 1 = write, 0 = read
    reg test_mode;

    // Outputs
    wire [7:0] data_out;

    // Instantiate the Unit Under Test (UUT)
    testing_bisr uut (
        .clk(clk),
        .reset(reset),
        .addr(addr),
        .data_in(data_in),
        .rw(rw),
        .test_mode(test_mode),
        .data_out(data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Stimulus
    initial begin
        // Initialize
        reset = 1;
        test_mode = 0;
        addr = 0;
        data_in = 0;
        rw = 0;
        #15 reset = 0;  // Deassert reset

        // Run BIST (test_mode = 1)
        #10; test_mode = 1;
        #20; test_mode = 0;   // Back to normal mode

        // Write 0x11..0xFF to addresses 0x1..0xE, reading back after each write
        #10; addr = 4'b0001; rw = 1; data_in = 8'h11;
        #10; rw = 0;
        #10 addr = 4'b0010; rw = 1; data_in = 8'h22;
        #10 rw = 0;
        #10 addr = 4'b0011; rw = 1; data_in = 8'h33;
        #10 rw = 0;
        #10 addr = 4'b0100; rw = 1; data_in = 8'h44;
        #10 rw = 0;
        #10 addr = 4'b0101; rw = 1; data_in = 8'h55;
        #10 rw = 0;
        #10 addr = 4'b0110; rw = 1; data_in = 8'h66;
        #10 rw = 0;
        #10 addr = 4'b0111; rw = 1; data_in = 8'h77;   // faulty address
        #10 rw = 0;
        #10 addr = 4'b1000; rw = 1; data_in = 8'h88;
        #10 rw = 0;
        #10 addr = 4'b1001; rw = 1; data_in = 8'h99;
        #10 rw = 0;
        #10 addr = 4'b1010; rw = 1; data_in = 8'hBB;
        #10 rw = 0;
        #10 addr = 4'b1011; rw = 1; data_in = 8'hCC;
        #10 rw = 0;
        #10 addr = 4'b1100; rw = 1; data_in = 8'hDD;
        #10 rw = 0;
        #10 addr = 4'b1101; rw = 1; data_in = 8'hEE;
        #10 rw = 0;
        #10 addr = 4'b1110; rw = 1; data_in = 8'hFF;   // faulty address
        #10 rw = 0;

        #20 $finish;
    end
endmodule
