`timescale 1ns/1ps
module fdiv_9_5_tb();
reg clk;
reg clr;
wire clk_div;

fdiv_9_5 F1(
    .clk(clk),
    .clr(clr),
    .clk_div(clk_div)
);

parameter ClockPeriod=10;
initial
	begin
		clk=0;
		forever
		#(ClockPeriod/2) clk=~clk;	
end   
initial begin
    clr = 0;
    #15;
    clr = 1;
    #10;
    clr = 0;
    #90;
    clr = 1;
    #10;
    clr = 0;
    #1000;
    $stop;
end
endmodule