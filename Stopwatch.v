module TFF0 (
data  , // Data Input
clk   , // Clock Input
reset , // Reset input
q       // Q output
);
//-----------Input Ports---------------
input data, clk, reset ; 
//-----------Output Ports---------------
output q;
//------------Internal Variables--------
reg q;
//-------------Code Starts Here---------
always @ ( posedge clk or posedge reset)
if (reset) begin
  q <= 1'b0;
end else if (data) begin
  q <= !q;
end

endmodule

module clk_divider(clock, rst, clk_in);
input clock, rst;
output clk_in;
 
wire [18:0] din;
wire [18:0] clkdiv;
 
DFF0 dff_inst0(
    .data_in(din[0]),
	 .clock(clock),
	 .reset(rst),
    .data_out(clkdiv[0])
);
 
genvar i;
generate
for (i = 1; i < 19; i=i+1) 
	begin : dff_gen_label
		 DFF0 dff_inst (
			  .data_in (din[i]),
			  .clock(clkdiv[i-1]),
			  .reset(rst),
			  .data_out(clkdiv[i])
		 );
		 end
endgenerate
 
assign din = ~clkdiv;
 
assign clk_in = clkdiv[18];
 
endmodule

module DFF0(data_in,clock,reset, data_out);
input data_in;
input clock,reset;

output reg data_out;

always@(posedge clock)
	begin
		if(reset)
			data_out<=1'b0;
		else
			data_out<=data_in;
	end	

endmodule

module halfAdder(x, y, sum, carry);

input[3:0] x, y;

output sum, carry;

assign sum = x^y;

assign carry = x&y;

endmodule

module RCA(x, cin, sum);

input [3:0] x;
input cin;
output [3:0]sum;

wire s1, c1, c2, c3, c4;

halfAdder HA1(x[0], cin, sum[0], c1);
halfAdder HA2(x[1], c1, sum[1], c2);
halfAdder HA3(x[2], c2, sum[2], c3);
halfAdder HA4(x[3], c3, sum[3], c4);

endmodule

module BCD_display(a,b,c,d,e,f,g, A, B, C, D);

input A, B, C, D;
output a, b, c, d, e, f, g;

assign a = B&~C&~D | ~A&~B&~C&D;
assign b = B&(C^D);
assign c = ~B&C&~D;
assign d = ~B&~C&D | B&~(C^D);
assign e = D | (B&~C);
assign f = C&D | ~B&C | ~A&~B&D;
assign g = (~A&~B&~C)|(B&C&D);

endmodule

module count10(clock, inc, reset, count, count_eq_9);

input clock, inc, reset;
output [3:0] count;
output count_eq_9;

wire f, w1, w2;
wire [3:0] rcaout;

DFF0 DFF1(rcaout[0],clock, w2, count[0]);
DFF0 DFF2(rcaout[1],clock, w2, count[1]);
DFF0 DFF3(rcaout[2],clock, w2, count[2]);
DFF0 DFF4(rcaout[3],clock, w2, count[3]);

RCA RCA1(count, inc, rcaout);

assign count_eq_9 = (count == 4'b1001)?1:0;

and g1 (w1, count_eq_9, inc);
or g2 (w2, reset, w1);

endmodule

module count6(clock, inc, reset, count, count_eq_9);

input clock, inc, reset;
output [3:0] count;
output count_eq_9;

wire f, w1, w2;
wire [3:0] rcaout;

DFF0 DFF1(rcaout[0],clock, w2, count[0]);
DFF0 DFF2(rcaout[1],clock, w2, count[1]);
DFF0 DFF3(rcaout[2],clock, w2, count[2]);
DFF0 DFF4(rcaout[3],clock, w2, count[3]);
RCA RCA1(count, inc, rcaout);

assign count_eq_9 = (count == 4'b0101)?1:0;

and g1 (w1, count_eq_9, inc);
or g2 (w2, reset, w1);

endmodule

module Stopwatch(clock, inc, reset, data, a1, a2, a3, a4, b1, b2, b3, b4, c1, c2, c3, c4, d1, d2, d3, d4, e1, e2, e3, e4, f1, f2, f3, f4, g1, g2, g3, g4);

input clock, inc, reset, data;
output a1, b1, c1, d1, e1, f1, g1;
output a2, b2, c2, d2, e2, f2, g2;
output a3, b3, c3, d3, e3, f3, g3;
output a4, b4, c4, d4, e4, f4, g4;
wire clk_out, ceq1, ceq2, ceq3, ceq4, Q;
wire w1, w2, w3;
wire [3:0] O1, O2, O3, O4;

clk_divider CLK_divider(clock, reset, clk_out);

count10 count1(clk_out, Q, reset, O1, ceq1);
count10 count2(clk_out, w1, reset, O2, ceq2);
count10 count3(clk_out, w2, reset, O3, ceq3);
count6 count4(clk_out, w3, reset, O4, ceq4);

BCD_display display1(a1, b1, c1, d1, e1, f1, g1, O1[3], O1[2], O1[1], O1[0]);
BCD_display display2(a2, b2, c2, d2, e2, f2, g2, O2[3], O2[2], O2[1], O2[0]);
BCD_display display3(a3, b3, c3, d3, e3, f3, g3, O3[3], O3[2], O3[1], O3[0]);
BCD_display display4(a4, b4, c4, d4, e4, f4, g4, O4[3], O4[2], O4[1], O4[0]);

//data is the push button

TFF0 tff0(1'b1, data, reset, Q);

and p1(w1, ceq1, Q);
and p2(w2, ceq2, w1);
and p3(w3, ceq3, w2);

endmodule