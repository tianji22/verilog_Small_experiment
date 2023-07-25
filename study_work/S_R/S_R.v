`timescale 100ns/1ns
/*
Clk	1	脉冲输入。1Khz时钟信号，上升沿有效。
Rst	1	电平输入。异步清零信号，高电平清零。
S_P	1	脉冲输入。计数启停，上升沿有效，每输入一个S_P，计数或停止状态就发生改变。
Rev	1	脉冲输入。存储的计数结果回放信号，上升沿有效，按照先存储先播放原则回放存储的数据。输入一个Rev脉冲，回放一个数据。
Dis_LED	8	电平输出。2位十六进制LED输出，在S_P有效时播放计数结果，在Rev有效时显示存储的数据。
R_S	1	电平输出。高电平表示回放，低电平表示存储。
*/
module S_R (
    input clk,
    input rst,
    input S_P,
    input Rev,
    output reg [7:0] Dis_LED,
    output reg R_S
);
    reg [7:0] cnt_16;
    reg [1:0] test_Rev;
    reg [1:0] adr_add;
    reg [7:0] sram_16[7:0];
    reg [3:0] adr;
    reg [2:0] readr;
    wire full;
    integer i;
    reg [3:0]readr2;
    wire adr_en;
    reg S_P_in;
    wire Rev_in;
//----------------------------------------------------------分频器--------------------------------------------------------//
always@( posedge S_P)begin
    S_P_in = ~S_P_in;
end
//----------------------------------------------------------边沿检测------------------------------------------------------//
always @(posedge clk,posedge rst) begin
    if(rst) begin
        test_Rev <= 0;
        S_P_in <= 0;
        adr_add <= 0;
    end
    else begin
        test_Rev[0] <= Rev;
        test_Rev[1] <= test_Rev[0];//回放上升沿
        adr_add[0] <= S_P_in;
        adr_add[1] <= adr_add[0];//存储计数上升沿
    end
end
assign Rev_in = rst ? 0:((test_Rev==2'b01)? 1:0);//回放输出，计数使能
assign adr_en = rst ? 0:((adr_add==2'b10)? 1:0);//存储地址加一使能

//----------------------------------------------------------计数器--------------------------------------------------------//
always@(posedge clk ,posedge rst)begin
    if(rst)begin
        cnt_16 <= 0;
        Dis_LED <= 0;
    end
    else begin
        if(S_P_in) begin
            cnt_16 <= cnt_16 + 1'b1;
            Dis_LED <= cnt_16;//显示计数器的数
        end
        else begin
            cnt_16 <= cnt_16;
        end
    end
end
//---------------------------------------------------------存入寄存器------------------------------------------------------//
always@(posedge clk ,posedge rst)begin
    if(rst)begin
        adr <= 0;
        R_S <= 0;
        for(i=0;i<=7;i=i+1)sram_16[i] <= 0;
    end
    else begin
        if( adr_en ) begin
                R_S <= 0;
            if( adr <= 7)begin
                sram_16[adr] <= cnt_16;
                adr <= adr+1'b1;
                Dis_LED <= cnt_16;
                readr2 <= adr+1'b1;
            end
            else begin
                sram_16[0] <= cnt_16;
                adr <= 1;
                Dis_LED <= cnt_16;
                readr2 <= 1;
            end
        end
    end
end
//---------------------------------------------------------是否存满--------------------------------------------------------//
assign full = rst ? 0:((adr==8)? 1:full);//写地址只要有一次等于8则存满，且所存状态。
//--------------------------------------------------------------回放-------------------------------------------------------//
always@(posedge clk ,posedge rst) begin
    if(rst) begin
        Dis_LED <= 0;
        readr <= 0; 
        readr2 <= 0;
    end
    else begin
        if(Rev_in) begin
            R_S <= 1;
            if(full)begin//存满了
                if( readr2 <= 7)begin//写地址小于等于7
                    Dis_LED <= sram_16[readr2];
                    readr2 <= readr2 + 1'b1;
                end
                else begin//写地址大于7
                    Dis_LED <= sram_16[0];
                    readr2 <=1'b1;
                end
            end
            else begin//没存满从头开始读
                Dis_LED <= sram_16[readr];//显示存储的数
                readr <= readr + 1'b1;
            end
         end
    end
end
endmodule