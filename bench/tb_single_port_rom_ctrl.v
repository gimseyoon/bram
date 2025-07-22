`timescale 1ns / 1ps

module tb_single_port_rom_ctrl(

    );
    
reg clk;
reg rst;
reg start_r;
wire [15:0] data_out;
wire done;


always #5 clk = ~clk;

single_port_rom_ctrl uut(
.clk(clk),
.rst(rst),
.start_r(start_r),
.data_out(data_out),
.done(done)
);

initial begin
start_r = 0;
#300 start_r = 1;
#10 start_r = 0;
end

initial begin
clk = 0; rst = 0; 
#250 rst = 1;
#10 rst = 0;
end

endmodule
