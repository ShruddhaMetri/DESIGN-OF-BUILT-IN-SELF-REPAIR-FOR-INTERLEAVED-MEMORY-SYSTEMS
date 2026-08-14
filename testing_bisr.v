`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: testing_bisr
// Project    : Power-Efficient Built-In Self-Repair (BISR) for Interleaved Memory
// Description: BIST + BIRA based self-repair for interleaved memory. On a faulty
//              address access, the redundant memory (RM) bank is used instead of
//              the main memory. Faulty addresses are 0x7 and 0xE.
//////////////////////////////////////////////////////////////////////////////////
module testing_bisr(
    input clk,
    input reset,
    input [3:0] addr,
    input [7:0] data_in,
    input rw,               // 1 = write, 0 = read
    input test_mode,
    output reg [7:0] data_out
);
    // memory banks
    reg [7:0] main_mem [0:15];
    reg [7:0] rm_mem [0:7];   // Redundant memory

    // faulty address register
    reg [3:0] faulty_addrs [0:2];
    reg [1:0] fault_count;

    // control signals
    reg use_rm;
    reg [2:0] rm_addr;        // 3 bits to access 8-entry rm_mem

    // pattern for test_mode
    reg [7:0] expected_pattern = 8'hAA;
    integer i;

    // initialization
    initial begin
        faulty_addrs[0] = 4'b0111;
        //faulty_addrs[1] = 4'b1000;
        faulty_addrs[2] = 4'b1110;
        for (i = 0; i < 16; i = i + 1)
            main_mem[i] = expected_pattern;   // initialize with known pattern
        for (i = 0; i < 8; i = i + 1)
            rm_mem[i] = 0;
        fault_count = 0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            fault_count <= 0;
            use_rm <= 0;
        end

        else if (test_mode) begin
            // Simulated BIST process: check for deviations from expected pattern
            fault_count <= 0;  // reset fault count for new test run
            for (i = 0; i < 16; i = i + 1) begin
                if (main_mem[i] !== expected_pattern && fault_count < 3) begin
                    faulty_addrs[fault_count] <= i[3:0];
                    fault_count <= fault_count + 1;
                end
            end
        end

        else begin
            use_rm <= 0;
            // Check if address is faulty
            for (i = 0; i < 3; i = i + 1) begin
                if (addr == faulty_addrs[i]) begin
                    use_rm <= 1;
                    rm_addr <= i[2:0];   // map to redundant memory
                end
            end
            // Perform read/write based on rw signal
            if (rw) begin  // write operation
                if (use_rm)
                    rm_mem[rm_addr] <= data_in;
                else
                    main_mem[addr] <= data_in;
            end
            else begin     // read operation
                if (use_rm)
                    data_out <= rm_mem[rm_addr];
                else
                    data_out <= main_mem[addr];
            end
        end
    end
endmodule
