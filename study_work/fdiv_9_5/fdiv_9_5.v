module fdiv_9_5 (
    input clk,
    input clr,
    output reg clk_div
);
    reg [4:0] cnt0;
    always@(posedge clk or posedge clr)begin
        if(clr)
            cnt0 <= 0;
        else
            begin
                if(cnt0 < 8)
                    cnt0 <= cnt0 + 1'b1;
                else
                    cnt0 <= 0;
            end  
    end
    always@(*)
        begin
            if(clr)
                clk_div = 0;
            else
                case (cnt0)
                    5'b00000:clk_div = clk;
                    5'b00010,5'b00100,5'b00110,5'b01000 : clk_div = 1'b0;
                    5'b00001,5'b00011,5'b00101,5'b00111 : clk_div = 1'b1;
                    default: clk_div = 0;
                endcase
        end
endmodule