module StackPointer(clk,rst,writeSP,addrin,addrout,isPOP);
input clk,rst,writeSP;
input [7:0] addrin;
input isPOP;
output [7:0] addrout;
reg [7:0] stackaddress;
assign addrout = stackaddress;
always@(negedge(clk),negedge(rst)) begin
    if(!rst)
        stackaddress <= 8'hff;//last address, decrement for push, increment for pop
    else begin
        if(isPOP && stackaddress == 8'hff && writeSP)
            stackaddress <= 8'hff;
        else if(writeSP)
            stackaddress <= addrin;
    end
end
endmodule
