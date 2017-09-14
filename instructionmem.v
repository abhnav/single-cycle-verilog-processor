module InstructionMemory(address,dataout,datain,clk,writeInstructionMem,rst);
input [8:0] address;
input clk,writeInstructionMem,rst;
input [15:0] datain;
output [15:0] dataout;
reg [15:0] memory[0:511];
assign dataout = memory[address];
integer i;
always@(negedge(clk),negedge(rst)) begin
    if(!rst) begin
        $readmemh("instructions",memory);
        //for(i = 0;i<511;i += 1) begin
            //memory[i] = 16'h0000;
        //end
    end
    else begin
        if(writeInstructionMem) begin
            memory[address] <= datain;
        end
    end
end
endmodule
