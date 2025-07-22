`timescale 1ns / 1ps

module single_port_rom_ctrl (
    input clk,
    input rst,
    input start_r,
    output [15:0] data_out,
    output done
);
///////////////////////////////////////////////
localparam IDLE = 1'b0, RUN = 1'b1;

///////////////////////////////////////////////
wire ena;
reg state, ns;
reg [6:0] addr;
reg [1:0] done_reg;

//////////////////////////////////////////////
assign ena = state;
assign done = done_reg[1];



// FSM(state)
always @(posedge clk or posedge rst) begin
    if (rst)
        state <= IDLE;
    else
        state <= ns;
end

// FSM(ns)
always @(*) begin
    case (state)
        IDLE:
            if (start_r)
                ns = RUN;
            else
                ns = IDLE;
        RUN:
            if (done_reg[1])
                ns = IDLE;
            else
                ns = RUN;
        default: ns = IDLE;
    endcase
end


// done
always @(posedge clk or posedge rst) begin
    if (rst) begin
        done_reg <= 0;
    end
    else begin
        done_reg[1] <= done_reg[0];
        if (addr == 7'd99) begin
            done_reg[0] <= 1;
        end
        else begin
            done_reg[0] <= 0;
        end
    end
end

// addr
always @(posedge clk or posedge rst) begin
    if (rst) begin
        addr <= 0;
    end
    else begin
        if (state == RUN) begin
            if (addr == 7'd99) begin
                addr <= 0;
            end
            else begin
                addr <= addr + 1;
            end
        end 
        else begin
            addr <= 0;
        end
    end 
end




blk_mem_gen_0 bram_0 (
  .clka(clk),
  .ena(ena),
  .addra(addr),
  .douta(data_out)
);


endmodule
