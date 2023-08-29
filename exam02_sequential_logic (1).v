`timescale 1ns / 1ps

module D_flip_flop_n (
        input d,
        input clk,
        input reset_p,
        output reg q
    );

    always @(negedge clk or posedge reset_p) begin
        if(reset_p) q = 0;
        else q = d;
    end
endmodule

module D_flip_flop_p (
        input d,
        input clk,
        input reset_p,
        output reg q
    );

    always @(posedge clk or posedge reset_p) begin
        if(reset_p) q = 0;
        else q = d;
    end
endmodule

module T_flip_flop_n (
        input clk,
        input reset_p,
        output reg q
    );
    
    always @(negedge clk or posedge reset_p)begin
        if(reset_p) q = 0;
        else        q = ~q;
    end

endmodule

module T_flip_flop_p (
        input clk,
        input t,
        input reset_p,
        output reg q
    );

    always @(posedge clk or posedge reset_p)begin
        if(reset_p) q = 0;
        else if(t) q = ~q;
        else q = q;
    end

endmodule

module up_counter_asyc(
        input clk,
        input reset_p,
        output [3:0] count
    );

    T_flip_flop_n T0 (.clk(clk), .reset_p(reset_p), .q(count[0]));
    T_flip_flop_n T1 (.clk(count[0]), .reset_p(reset_p), .q(count[1]));
    T_flip_flop_n T2 (.clk(count[1]), .reset_p(reset_p), .q(count[2]));
    T_flip_flop_n T3 (.clk(count[2]), .reset_p(reset_p), .q(count[3]));

endmodule

module down_counter_asyc(
        input clk,
        input reset_p,
        output [3:0] count
    );

    T_flip_flop_p T0 (.clk(clk), .reset_p(reset_p), .q(count[0]));
    T_flip_flop_p T1 (.clk(count[0]), .reset_p(reset_p), .q(count[1]));
    T_flip_flop_p T2 (.clk(count[1]), .reset_p(reset_p), .q(count[2]));
    T_flip_flop_p T3 (.clk(count[2]), .reset_p(reset_p), .q(count[3]));

endmodule

module up_counter_p(
        input clk,
        input reset_p,
        output reg [3:0] count
    );

    always @(posedge clk or posedge reset_p)begin
        if(reset_p) count = 0;
        else count = count + 1;
    end

endmodule

module down_counter_p(
        input clk,
        input reset_p,
        output reg [3:0] count
    );

    always @(posedge clk or posedge reset_p)begin
        if(reset_p) count = 0;
        else count = count - 1;
    end

endmodule

module up_down_counter_Nbit_p #(parameter N = 4)(
        input clk,
        input reset_p,
        input up_down,
        output reg [N-1:0] count
    );
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) count = 0;
        else if (up_down)  count = count + 1;
        else count = count - 1;
    end
endmodule

module counter_fnd_top(
    input clk, reset_p, btn1,
    output [7:0] seg_7,
    output [3:0] com
);

    wire [11:0] count;
    
    reg [25:0] clk_div;
    
    always @(posedge clk) clk_div = clk_div + 1;
    
    D_flip_flop_p (.d(btn1), .clk(clk_div[16]), .reset_p(reset_p), .q(up_down));
    
    wire up;
    T_flip_flop_p T_up (.clk(clk), .t(up_down), .reset_p(reset_p), .q(up));
    
    up_down_counter_Nbit_p #(.N(12)) counter_fnd (.clk(clk_div[25]), .reset_p(reset_p), .up_down(up),
        .count(count));
    wire [15:0] dec_value;
    bin_to_dec bin2dec (.bin(count), .bcd(dec_value));
        
    FND_4digit_cntr fnd_cntr (.clk(clk), .reset_p(reset_p), .value(dec_value),
         .com(com), .seg_7(seg_7));

endmodule

module up_down_counter_BCD_p(
        input clk,
        input reset_p,
        input up_down,
        output reg [3:0] count
    );

    always @(posedge clk or posedge reset_p)begin
        if(reset_p) count = 0;
        else begin
            if (up_down)begin
                if (count >= 9) count = 0;
                else count = count + 1;
            end
            else begin
                if(count == 0) count = 9;
                else count = count - 1;
            end
        end
    end

endmodule

module ring_counter_fnd(
        input clk, reset_p,
        output [3:0] com
    );

    reg [3:0] temp;

    always @(posedge clk or posedge reset_p)begin
        if(reset_p) temp = 4'b1110;
        else if (temp == 4'b0111) temp = 4'b1110;
        else temp = {temp[2:0], 1'b1};
    end
    
    assign com = temp;

endmodule

module FND_4digit_cntr(
        input clk, reset_p,
        input [15:0] value,
        output [3:0] com,
        output [7:0] seg_7
    );

    reg [16:0] clk_1ms;
    
    always @(posedge clk) clk_1ms = clk_1ms + 1;
    
    ring_counter_fnd ring_counter (.clk(clk_1ms[16]), .reset_p(reset_p), .com(com));
    
    reg [3:0] hex_value;
    
    decoder_7seg decoder (.hex_value(hex_value), .seg_7(seg_7));
    
    always @(negedge clk)begin
        case(com)
            4'b1110: hex_value = value[15:12];
            4'b1101: hex_value = value[11:8];
            4'b1011: hex_value = value[7:4];
            4'b0111: hex_value = value[3:0];
        endcase
    end

endmodule

module edge_detector_n (
        input clk,
        input cp_in,
        input reset_p,
        output p_edge,
        output n_edge
    );

    reg cp_in_old, cp_in_cur;
    
    always @(negedge clk or posedge reset_p)begin
        if(reset_p)begin cp_in_old = 0; cp_in_cur = 0; end
        else begin
            cp_in_old <= cp_in_cur;
            cp_in_cur <= cp_in;
            
        end
    end

    assign p_edge = ~cp_in_old & cp_in_cur;
    assign n_edge = cp_in_old & ~cp_in_cur;

endmodule















