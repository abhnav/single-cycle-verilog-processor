module DataMemory(address,dataout,datain,clk,writeDataMem,rst);//asynchronous active low reset
input [7:0] address;
input clk,writeDataMem,rst;
input [15:0] datain;
output [15:0] dataout;
reg [15:0] memory[0:255];
assign dataout = memory[address];
integer i;
always@(negedge(clk),negedge(rst)) begin
    if(!rst) begin
        $readmemh("data",memory);
        //for(i = 0;i<256;i += 1) begin
            //memory[i] = 16'h0000;
        //end
    end
    else begin
        if(writeDataMem) begin
            memory[address] <= datain;
        end
    end
end
endmodule
        
          


