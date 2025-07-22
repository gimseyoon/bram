`timescale 1ns / 1ps

module tb_single_port_ram_ctrl(

    );
    
reg clk;
reg rst;
reg start;
wire [15:0] data_out;
wire done_r;
wire done_w;


always #5 clk = ~clk;

single_port_ram_ctrl uut(
.clk(clk),
.rst(rst),
.start(start),
.data_out(data_out),
.done_w(done_w),
.done_r(done_r)
);

initial begin
start = 0;
#300 start = 1;
#10 start = 0;
end

initial begin
clk = 0; rst = 0; 
#250 rst = 1;
#10 rst = 0;
end

endmodule
