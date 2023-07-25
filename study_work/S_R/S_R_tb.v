`timescale 100ns/1ns
module S_R_tb ();
reg clk;
reg rst;
reg S_P;
reg Rev;
wire [7:0]Dis_LED;
wire R_S;
integer i;
integer k;
S_R S1(
    .clk(clk),
    .rst(rst),
    .S_P(S_P),
    .Rev(Rev),
    .Dis_LED(Dis_LED),
    .R_S(R_S)
);
parameter ClockPeriod=10;
initial begin
	clk=0;
	forever
	#(ClockPeriod/2) clk=~clk;	
end
initial begin
    Rev = 0;
    S_P = 0;
    #5;
    rst = 0;
    #10;
    rst = 1;
    #10;
    rst = 0;
    for(i = 0;i <= 9;i=i+1)begin
        S_P = 1;
        #50;
        S_P = 0;
        #50;
    end
    #900;
    for(k = 0;k <= 15;k=k+1)begin
        Rev = 1;
        #50;
        Rev = 0;
        #50;
    end
     rst = 0;
    #10;
    rst = 1;
    #10;
    rst = 0;
    for(i = 0;i <= 17;i=i+1)begin
        S_P = 1;
        #50;
        S_P = 0;
        #50;
    end
    #900;
    for(k = 0;k <= 15;k=k+1)begin
        Rev = 1;
        #50;
        Rev = 0;
        #50;
    end
    $stop;
end
endmodule