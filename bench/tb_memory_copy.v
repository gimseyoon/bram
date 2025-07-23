`timescale 1ns / 1ps

module tb_memory_copy;

    // Testbench signals
    reg clk;
    reg rst;
    reg start;
    wire [15:0] data_out;
    wire doneC;
    wire doneR;

    // Instantiate DUT (Device Under Test)
    memory_copy dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_out(data_out),
        .doneC(doneC),
        .doneR(doneR)
    );

    // Clock generation (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

//rst
initial begin
rst = 0;
#1000 rst = 1;
#10 rst = 0;
end

// start
initial begin
start = 0;
#1200 start = 1;
#10 start = 0;
end


endmodule
