`timescale 1ns / 1ps

module D_flip_flop_n (
        input d,
        input clk,
        input reset_p,
        output reg q
    );

    always @(negedge clk, posedge reset_p)begin
        if(reset_p) q=0;
        else q=d;
        q = d;
    end
endmodule

module D_flip_flop_p (
        input d,
        input clk,
        input reset_p,
        output reg q
    );

    always @(posedge clk or posedge reset_p)begin
        if(reset_p) q=0;
        else q = d;
    end
endmodule

module T_flip_flop_n (
        input clk,
        input reset_p,
        output reg q = 0
    );


    always @(negedge clk or posedge reset_p)begin
        q = ~q;
    end

endmodule

module T_flip_flop_p (
        input clk,
        input reset_p,
        output reg q = 0
    );


    always @(posedge clk or posedge reset_p)begin
        q = ~q;
    end

endmodule

module up_counter_asyc(
    input clk,
    input reset_p,
    output [3:0] count
    );
   
T_flip_flop_n T0(.clk(clk), .reset_p(reset_p), .q(count[0]));
T_flip_flop_n T1(.clk(count[0]), .reset_p(reset_p), .q(count[1]));
T_flip_flop_n T2(.clk(count[1]), .reset_p(reset_p), .q(count[2]));
T_flip_flop_n T3(.clk(count[2]), .reset_p(reset_p), .q(count[3]));


endmodule

module down_counter_asyc(
    input clk,
    input reset_p,
    output [3:0] count
    );
   
T_flip_flop_p T0(.clk(clk), .reset_p(reset_p), .q(count[0]));
T_flip_flop_p T1(.clk(count[0]), .reset_p(reset_p), .q(count[1]));
T_flip_flop_p T2(.clk(count[1]), .reset_p(reset_p), .q(count[2]));
T_flip_flop_p T3(.clk(count[2]), .reset_p(reset_p), .q(count[3]));


endmodule

module up_counter_p(
input clk,
input reset_p,
output reg[3:0] count

);


always @(posedge clk or posedge reset_p)begin
    if(reset_p) count=0;
    else count = count+1;
end


endmodule


module down_counter_p(
input clk,
input reset_p,
output reg[3:0] count

);


always @(posedge clk or posedge reset_p)begin
    if(reset_p) count=0;
    else count = count-1;
end


endmodule

module up_down_counter(
    input clk,reset_p,
    input up_down,
    output reg[3:0] count
    );
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) count=0;
        else if(up_down) count = count+1;
        else count=count-1;
    end
    
    endmodule


module counter_fnd_top(
    input clk,reset_p, up_down,
    output [7:0] seg_7,
    output [3:0] com
);

    wire[3:0] count;
    
    assign com = 4'b0000;
    
    reg[25:0] clk_div;
    
    always @(posedge clk) clk_div = clk_div+1;

up_down_counter counter_fnd(.clk(clk_div[25]), .reset_p(reset_p), .up_down(up_down),
    .count(count));
    
   decoder_7seg(.hex_value(count), .seg_7(seg_7));


endmodule















