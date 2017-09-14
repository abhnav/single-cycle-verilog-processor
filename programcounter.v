module ProgramCounter(clk,rst,addrin,addrout);//have to check if there should be a writePC
input clk,rst;
input [8:0] addrin;
output [8:0] addrout;
reg [8:0] curaddress;
assign addrout = curaddress;
always@(negedge(clk),negedge(rst)) begin
    if(!rst)
        curaddress <= 9'b0;//can set it to point to last address like intel processors
    else 
        curaddress <= addrin;
end
endmodule
