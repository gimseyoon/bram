`timescale 1ns / 1ps

module true_dual_port_ram_ctrl(
    input clk,
    input rst,
    input start_w,
    input start_r,
    output [15:0] douta,
    output [15:0] doutb,
    output done_w,
    output done_r
    );
    
    localparam IDLE = 2'b00, WRITE = 2'b01, WAIT = 2'b10, READ = 2'b11;
    
    //////////////////////////////////////////////////
    reg [1:0] done_w_reg;
    reg [1:0] done_r_reg;
    reg [5:0] cnt_w;
    reg [5:0] cnt_r;
    reg [1:0] state;
    reg [1:0] ns;
    //port a
    reg ena;
    reg wea;
    reg [6:0] addra;
    reg [15:0] dina;
    //port b
    reg enb;
    reg web;
    reg [6:0] addrb;
    reg [15:0] dinb;
    //////////////////////////////////////////////
    assign done_w = done_w_reg[0];
    assign done_r = done_r_reg[1];
    
    /////////////////////////////////////////////
    // FSM
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;
        end
        else begin
            state <= ns;
        end
    end
    
    always@(*) begin
        case(state)
            IDLE: if(start_w) ns = WRITE;
            WRITE: if(cnt_w == 6'd50) ns = WAIT;
            WAIT: if(start_r) ns = READ;
            READ: if(cnt_r == 6'd52) ns = IDLE;
            default: ns <= IDLE;
        endcase
    end
    
    
    ///////////////////////////////////////////////
    // ena, enb, wea, web, cnt, addra, addrb
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            ena <= 0;
            enb <= 0;
            wea <= 0;
            web <= 0;
            cnt_w <= 0;
            cnt_r <= 0;
            addra <= 7'd127;
            addrb <= 49;
            dina <= 0;
            dinb <= 50;
        end
        else begin
            case(state)
                WRITE:
                    if( cnt_w >= 6'd50) begin
                        ena <= 0;
                        enb <= 0;
                        wea <= 0;
                        web <= 0; 
                        cnt_w <= 0;
                        cnt_r <= 0;
                        addra <= 7'd127;
                        addrb <= 49; 
                        dina <= 0;
                        dinb <= 50;                       
                    end
                    else begin
                        ena <= 1;
                        enb <= 1;
                        wea <= 1;
                        web <= 1;
                        cnt_w <= cnt_w + 1;
                        cnt_r <= 0;
                        addra <= addra + 1;
                        addrb <= addrb + 1;
                        dina <= dina + 1;
                        dinb <= dinb + 1;    
                    end
                WAIT: 
                    begin
                        ena <= 0;
                        enb <= 0;
                        wea <= 0;
                        web <= 0;
                        cnt_w <= 0;
                        cnt_r <= 0;
                        addra <= 7'd127;
                        addrb <= 49; 
                        dina <= 0;
                        dinb <= 50;   
                    end 
                READ:
                    if( cnt_r >= 6'd52) begin
                        ena <= 0;
                        enb <= 0;
                        wea <= 0;
                        web <= 0; 
                        cnt_w <= 0;
                        cnt_r <= 0;
                        addra <= 7'd127;
                        addrb <= 49; 
                        dina <= 0;
                        dinb <= 50;   
                    end
                    else begin
                        ena <= 1;
                        enb <= 1;
                        wea <= 0;
                        web <= 0; 
                        cnt_r <= cnt_r + 1; 
                        cnt_w <= 0;
                        addra <= addra + 1;
                        addrb <= addrb + 1;  
                        dina <= dina + 1;
                        dinb <= dinb + 1;    
                    end
                default:
                    begin
                        ena <= 0;
                        enb <= 0;
                        wea <= 0;
                        web <= 0;
                        cnt_r <= 0;
                        cnt_w <= 0;
                        addra <= 7'd127;
                        addrb <= 49; 
                        dina <= 0;
                        dinb <= 50;   
                    end 
            endcase
        end //else (rst)
    end //always

    
///////////////////////////////////////////////////////
// done_w, done_r

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            done_w_reg <= 0;
            done_r_reg <= 0;
        end
        else begin
        
            done_w_reg[1] <= done_w_reg[0];
            done_r_reg[1] <= done_r_reg[0]; 
            
            case(state)
                WRITE:
                    if( cnt_w == 6'd50) begin
                        done_w_reg[0] <= 1;
                    end
                    else begin
                        done_w_reg[0] <= 0;
                    end
                WAIT: 
                    begin
                        done_w_reg[0] <= 0;
                        done_r_reg <= 0;
                    end 
                READ:
                    if( cnt_r == 6'd50) begin
                        done_r_reg[0] <= 1;
                    end
                    else begin
                        done_r_reg[0] <= 0;
                    end
                default:
                    begin
                        done_w_reg <= 0;
                        done_r_reg <= 0;
                    end 
            endcase
        end //else (rst)
    end //always
    
blk_mem_gen_3 your_instance_name (
  .clka(clk),    // input wire clka
  .ena(ena),      // input wire ena
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [5 : 0] addra
  .dina(dina),    // input wire [15 : 0] dina
  .douta(douta),  // output wire [15 : 0] douta
  .clkb(clk),    // input wire clkb
  .enb(enb),      // input wire enb
  .web(web),      // input wire [0 : 0] web
  .addrb(addrb),  // input wire [5 : 0] addrb
  .dinb(dinb),    // input wire [15 : 0] dinb
  .doutb(doutb)  // output wire [15 : 0] doutb
);


endmodule
