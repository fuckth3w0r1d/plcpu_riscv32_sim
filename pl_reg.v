module pl_reg #(parameter WIDTH = 32)(
    input clk, rst, 
    input [WIDTH-1:0] in,
    output reg [WIDTH-1:0] out
    );
    
    always@(posedge clk, posedge rst)
      begin
            if(rst)
                out <= 0;
            else if(flush)      // 冲刷流水线
                out <= 0;
            else if(!stall)     // 非阻塞则继续
                out <= in;
      end
    
endmodule
