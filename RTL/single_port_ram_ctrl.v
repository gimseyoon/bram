`timescale 1ns / 1ps
module single_port_ram_ctrl(
    input clk,
    input rst,
    input start,
    output [15:0] data_out,
    output done_w,
    output done_r
    );

localparam IDLE = 2'b00, WRITE = 2'b01, WRITE_DONE=2'b10, READ = 2'b11;

reg [1:0] state;
reg [1:0] ns;
reg wen;
reg ena;
reg [6:0] addr;
reg [15:0] din;
reg [1:0] done_w_reg; //for delay
reg [1:0] done_r_reg; //for delay

assign done_w = done_w_reg[1];
assign done_r = done_r_reg[1];

/////////////////////////////////////////////////////
//FSM 
always@(posedge clk or posedge rst) begin
    if(rst) begin
        state <= 0;
    end
    else begin
        state <= ns;
    end
end

always@(*) begin
    case(state)
        IDLE:
            if(start) ns <= WRITE;
            else ns <= ns;
        WRITE: 
            if(done_w) ns <= WRITE_DONE;
            else ns <= ns;
        WRITE_DONE: 
            ns <= READ; 
        READ: 
            if(done_r) ns <= IDLE;
            else ns <= ns;
        default: ns <= IDLE;
    endcase
end

/////////////////////////////////////////////////////
//addr
always@(posedge clk or posedge rst) begin
    if(rst) begin
        addr <= 0;
    end
    else begin
        if(state == WRITE || state == READ) begin
            if(addr == 7'd99) begin
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

/////////////////////////////////////////////////////
//wen, en
always@(*) begin
    if(state == WRITE) begin
        wen <= 1;
        ena <= 1;
    end
    else if(state == READ) begin
        wen <= 0;
        ena <= 1;
    end
    else begin
        wen <= 0;
        ena <= 0;
    end

end

/////////////////////////////////////////////////////
//done_w, done_r
always@(posedge clk or posedge rst) begin
    if(rst) begin
        done_w_reg <= 0;
        done_r_reg <= 0;
    end
    else begin
        done_w_reg[1] <= done_w_reg[0];
        done_r_reg[1] <= done_r_reg[0];
        if(state==WRITE && addr==7'd99) begin
            done_w_reg[0] <= 1;
            done_r_reg[0] <= 0;
        end
        else if(state==READ && addr==7'd99) begin
            done_w_reg[0] <= 0;
            done_r_reg[0] <= 1;
        end
        else begin
            done_w_reg[0] <= 0;
            done_r_reg[0] <= 0;
        end
    end
end


/////////////////////////////////////////////////////
// din
always@(posedge clk or posedge rst) begin
    if(rst) begin
        din <= 1;
    end
    else begin
        if(din==7'd100) begin
            din <= 1;
        end
        else begin
            if(state==WRITE) begin
                din <= din + 1;
            end
            else begin
                din <= 1;
            end         
        end
    end
end



blk_mem_gen_1 uut (
  .clka(clk),    // input wire clka
  .ena(ena),      // input wire ena
  .wea(wen),      // input wire [0 : 0] wea
  .addra(addr),  // input wire [6 : 0] addra
  .dina(din),    // input wire [15 : 0] dina
  .douta(data_out)  // output wire [15 : 0] douta
);

    
    
endmodule
