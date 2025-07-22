`timescale 1ns / 1ps

module simple_dual_port_ram_ctrl(
    input clk,
    input rst,
    input start_w,
    input start_r,
    output [15:0] doutb,
    output done_w,
    output done_r
    );
    
    localparam IDLE = 2'b00, WRITE = 2'b01, WRITE_READ = 2'b11; 
    
    reg [7:0] cnt_a;
    reg [6:0] cnt_b;
    reg [6:0] addra;
    reg [6:0] addrb;
    reg [15:0] dina;
    reg ena;
    reg enb;
    reg wea;
    reg [1:0] state;
    reg [1:0] ns;
    reg [1:0] done_w_reg;
    reg [1:0] done_r_reg;
    
    ///////////////////////////////////////////////////
    assign done_w = done_w_reg[1];
    assign done_r = done_r_reg[1];
    
    
   
    ///////////////////////////////////////////////////
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
        ns = state;
        case(state)
            IDLE: 
                if(start_w)   ns = WRITE;
                else          ns = IDLE;
            WRITE:
                if(start_r)   ns = WRITE_READ;
                else          ns = WRITE;
            WRITE_READ:
                if(done_r)    ns = IDLE;
                else          ns = WRITE_READ;
                
            default:         ns = IDLE;
        endcase
    end
    
    
    ////////////////////////////////////////////////////////////
    // addra, addrb
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            addra <= 7'd127;
            addrb <= 0;    
        end
        else begin
            //addra
            if(state==WRITE || state==WRITE_READ ) begin
                if(cnt_a >= 7'd100) begin
                    addra <= 0;
                end
                else begin
                    addra <= addra + 1;
                end
            end
            else begin
                addra <= 7'd127;
            end
            
            //addrb
            if(state==WRITE_READ) begin
                if(cnt_b >= 7'd99) begin
                    addrb <= 0;
                end
                else begin
                    addrb <= addrb + 1;
                end
            end
            else begin
                addrb <= 0;
            end
            
        end //else (rst)
    end //always
    
    ////////////////////////////////////////////////////////////////
    // dina
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            dina <= 0;    
        end
        else begin
            if(cnt_a >= 7'd100) begin
                dina <= 0;
            end
            else begin
                if( state==WRITE || state == WRITE_READ ) begin
                    dina <= dina + 1;
                end
                else begin
                    dina <= 0;
                end
            end

        end //else (rst)
    end //always
    
    
    
    ////////////////////////////////////////////////////////////////
    // cnt_a, cnt_b
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            cnt_a <= 0;
        end
        else begin
            if( (state==WRITE) || (state==WRITE_READ) ) begin
                cnt_a <= cnt_a + 1;
            end
            else begin
                cnt_a <= 0;
            end
        end
    end //always
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            cnt_b <= 0;
        end
        else begin
            if( state==WRITE_READ ) begin
                cnt_b <= cnt_b + 1;
            end
            else begin
                cnt_b <= 0;
            end
        end
    end //always
    
    /////////////////////////////////////////////////////////
    // ena, enb, wea
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            ena <= 0;
            enb <= 0;
            wea <= 0;
        end
        else begin
            
            //wea
            if(state == WRITE || state == WRITE_READ) begin
                if(cnt_a < 7'd100) begin
                    wea <= 1;
                    ena <= 1;
                end else begin
                    wea <= 0;
                    ena <= 0;
                end
            end else begin
                wea <= 0;
                ena <= 0;
            end

            //enb
            if(done_r) begin
                enb <= 0;
            end
            else if(start_r || state==WRITE_READ) begin
                enb <= 1;
            end
            else begin
                enb <= 0;
            end
            
            
        end // else (rst)
    end //always
    
    ////////////////////////////////////////////////////////////////
    // done_w, done_r
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            done_w_reg <= 0;
            done_r_reg <= 0;
        end
        else begin
            done_w_reg[1] <= done_w_reg[0];
            done_r_reg[1] <= done_r_reg[0];
            
            //done_w_reg
            if(cnt_a==7'd99) begin
                done_w_reg[0] <= 1;
            end
            else begin
                done_w_reg[0] <= 0;
            end
            
            //done_r_reg
            if(cnt_b==7'd99) begin
                done_r_reg[0] <= 1;
            end
            else begin
                done_r_reg[0] <= 0;
            end
           
        end // else (rst)
    end //always
    
    
    
    
    
    /////////////////////////////////////////////////////
    // instantiation
    
    blk_mem_gen_2 simple_dual_port_0 (
      .clka(clk),    // input wire clka
      .ena(ena),      // input wire ena
      .wea(wea),      // input wire [0 : 0] wea
      .addra(addra),  // input wire [6 : 0] addra
      .dina(dina),    // input wire [15 : 0] dina
      .clkb(clk),    // input wire clkb
      .enb(enb),      // input wire enb
      .addrb(addrb),  // input wire [6 : 0] addrb
      .doutb(doutb)  // output wire [15 : 0] doutb
    );

endmodule   