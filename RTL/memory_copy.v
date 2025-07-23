`timescale 1ns / 1ps

module memory_copy(
    input clk,
    input rst,
    input start,
    output [15:0] data_out,
    output reg doneC,
    output reg doneR
    );

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
reg [3:0] row;
reg [7:0] col;

// single port rom
reg [3:0] rom_en;
reg [7:0] rom_addr;
wire [15:0] rom_dout;
//simple dual port ram
reg ena;
reg wea;
wire [7:0] addra;
reg [15:0] dina;
reg enb;
reg [7:0] addrb;


/////////////////////////////////////////////////////////////////////
assign addra = col + row;


////////////////////////////////////////////////////////////////
// rom_addr, rom_en
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            rom_addr <= 8'd255;
            rom_en <= 0;
        end
        else begin
            rom_en[3] <= rom_en[2];
            rom_en[2] <= rom_en[1];
            rom_en[1] <= rom_en[0];
            if(start) begin
                rom_en[0] <= 1;
            end
            
            if(rom_en[0]) begin
                if(rom_addr==8'd197) begin
                    rom_en <= 0;
                    rom_addr <= 0;
                end
                else begin
                    rom_addr <= rom_addr + 1;
                end
            end
           
        end //else
    end //always
    
    
////////////////////////////////////////////////////////////////
// addra = col14 + row
always @(posedge clk or posedge rst) begin
    if (rst) begin
        row   <= 0;
        col   <= 0;
    end 
    else begin
        if(rom_en[3])begin
            if(col>= 8'd182) begin
                col <= 0;
                row <= row+1;
            end
            else begin
                col <= col + 14;
            end
        end
        else begin
            row <= 0;
            col <= 0;
        end
    end //else
end //always


////////////////////////////////////////////////////////////////
// doneC

always@(posedge clk or posedge rst) begin
    if(rst) begin
        doneC <= 0;
    end
    else begin
        if(addra==8'd195) begin
            doneC <= 1;
        end
        else begin
            doneC <= 0;
        end
    end
end



////////////////////////////////////////////////////////////////
// addrb, enb

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            addrb <= 8'd255;
            enb <= 0;
        end
        else begin
            if(doneC) begin
                enb <= 1;
            end
            
            if(enb) begin
                if(addrb==8'd197) begin
                    enb <= 0;
                    addrb <= 0;
                end
                else begin
                    addrb <= addrb + 1;
                end
            end
           
        end //else
    end //always



////////////////////////////////////////////////////////////////
// doneR_reg
always @(posedge clk or posedge rst) begin
    if (rst) begin
        doneR <= 0;
    end
    else begin
        if(addrb == 8'd196) begin
            doneR <= 1;
        end
        else begin
            doneR <= 0;
        end
    end
end




/////////////////////////////////////////////////////////////////
//instantiation

blk_mem_gen_4 single_port_rom_uut (
  .clka(clk),    // input wire clka
  .ena(rom_en[0]),      // input wire ena
  .addra(rom_addr),  // input wire [7 : 0] addra
  .douta(rom_dout)  // output wire [15 : 0] douta
);


blk_mem_gen_5 simple_dual_port_ram_uut (
  .clka(clk),    // input wire clka
  .ena(rom_en[3]),      // input wire ena
  .wea(rom_en[3]),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [7 : 0] addra
  .dina(rom_dout),    // input wire [15 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(enb),      // input wire enb
  .addrb(addrb),  // input wire [7 : 0] addrb
  .doutb(doutb)  // output wire [15 : 0] doutb
);

endmodule
