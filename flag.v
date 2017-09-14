module flags(datain,dataout,clk,rst);//flag should always be written
input [3:0] datain;
input rst,clk;
output [3:0] dataout;
reg [3:0] flags;
assign dataout = flags;
always@(negedge(rst),negedge(clk)) begin
    if(!rst) begin
        flags <= 4'b0000;
    end
    else begin
        flags <= datain;
    end
end
endmodule
