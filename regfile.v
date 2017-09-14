module RegisterFile(d,s1,s2,clk,rst,writeReg,datain,dout,s1out,s2out);
input clk,rst,writeReg;
input [3:0] d,s1,s2;
input [15:0] datain;
output [15:0] dout,s1out,s2out;
reg [15:0] regfile[0:15];
integer i;
assign dout = regfile[d];
assign s1out = regfile[s1];
assign s2out = regfile[s2];
always@(negedge(rst),negedge(clk)) begin
    if(!rst) begin
        for(i = 0;i<16;i += 1) begin
            regfile[i] <= 16'h0000;
        end
    end
    else begin
        if(writeReg) begin
            regfile[d] <= datain;
        end
    end
end
endmodule

