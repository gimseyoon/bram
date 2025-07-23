`timescale 1ns / 1ps

module tb_true_dual_port_ram_ctrl(

    );
    
reg clk;
reg rst;
reg start_w;
reg start_r;
wire [15:0] douta;
wire [15:0] doutb;
wire done_w;
wire done_r;

    
    
always #5 clk = ~clk;

true_dual_port_ram_ctrl true_dual_port_ram_uut(
.clk(clk),
.rst(rst),
.start_w(start_w),
.start_r(start_r),
.douta(douta),
.doutb(doutb),
.done_w(done_w),
.done_r(done_r)
);


// clk, rst
initial begin
clk = 0; rst = 0; 
#800 rst = 1;
#10 rst = 0;
end


// start_w, start_r
initial begin
start_w = 0;
start_r = 0;
#1000 start_w = 1;
#10 start_w = 0;
#600 start_r = 1;
#10 start_r = 0;
end




endmodule