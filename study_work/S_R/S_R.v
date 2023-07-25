`timescale 100ns/1ns
/*
Clk	1	�������롣1Khzʱ���źţ���������Ч��
Rst	1	��ƽ���롣�첽�����źţ��ߵ�ƽ���㡣
S_P	1	�������롣������ͣ����������Ч��ÿ����һ��S_P��������ֹͣ״̬�ͷ����ı䡣
Rev	1	�������롣�洢�ļ�������ط��źţ���������Ч�������ȴ洢�Ȳ���ԭ��طŴ洢�����ݡ�����һ��Rev���壬�ط�һ�����ݡ�
Dis_LED	8	��ƽ�����2λʮ������LED�������S_P��Чʱ���ż����������Rev��Чʱ��ʾ�洢�����ݡ�
R_S	1	��ƽ������ߵ�ƽ��ʾ�طţ��͵�ƽ��ʾ�洢��
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
//----------------------------------------------------------��Ƶ��--------------------------------------------------------//
always@( posedge S_P)begin
    S_P_in = ~S_P_in;
end
//----------------------------------------------------------���ؼ��------------------------------------------------------//
always @(posedge clk,posedge rst) begin
    if(rst) begin
        test_Rev <= 0;
        S_P_in <= 0;
        adr_add <= 0;
    end
    else begin
        test_Rev[0] <= Rev;
        test_Rev[1] <= test_Rev[0];//�ط�������
        adr_add[0] <= S_P_in;
        adr_add[1] <= adr_add[0];//�洢����������
    end
end
assign Rev_in = rst ? 0:((test_Rev==2'b01)? 1:0);//�ط����������ʹ��
assign adr_en = rst ? 0:((adr_add==2'b10)? 1:0);//�洢��ַ��һʹ��

//----------------------------------------------------------������--------------------------------------------------------//
always@(posedge clk ,posedge rst)begin
    if(rst)begin
        cnt_16 <= 0;
        Dis_LED <= 0;
    end
    else begin
        if(S_P_in) begin
            cnt_16 <= cnt_16 + 1'b1;
            Dis_LED <= cnt_16;//��ʾ����������
        end
        else begin
            cnt_16 <= cnt_16;
        end
    end
end
//---------------------------------------------------------����Ĵ���------------------------------------------------------//
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
//---------------------------------------------------------�Ƿ����--------------------------------------------------------//
assign full = rst ? 0:((adr==8)? 1:full);//д��ַֻҪ��һ�ε���8�������������״̬��
//--------------------------------------------------------------�ط�-------------------------------------------------------//
always@(posedge clk ,posedge rst) begin
    if(rst) begin
        Dis_LED <= 0;
        readr <= 0; 
        readr2 <= 0;
    end
    else begin
        if(Rev_in) begin
            R_S <= 1;
            if(full)begin//������
                if( readr2 <= 7)begin//д��ַС�ڵ���7
                    Dis_LED <= sram_16[readr2];
                    readr2 <= readr2 + 1'b1;
                end
                else begin//д��ַ����7
                    Dis_LED <= sram_16[0];
                    readr2 <=1'b1;
                end
            end
            else begin//û������ͷ��ʼ��
                Dis_LED <= sram_16[readr];//��ʾ�洢����
                readr <= readr + 1'b1;
            end
         end
    end
end
endmodule