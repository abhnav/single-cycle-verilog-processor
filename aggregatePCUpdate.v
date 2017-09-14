`include "programcounter.v"
`include "pcadder.v"
`include "multiplexers.v"
`include "datamem.v"
`include "alu.v"
`include "instructionmem.v"
`include "alucontrol.v"
`include "flag.v"
`include "stackpointer.v"
`include "regfile.v"

module tb_aggregate();
reg clk,rst;
aggregateALL process(clk,rst);
initial begin
    clk = 1'b0;
    rst = 1'b0;//active low reset
    #1 rst = 1'b1;
    #220 $finish;
end
always@(clk) begin
    #5 clk <= ~clk;
end
initial begin
    $dumpfile("processor.vcd");
    $dumpvars;
end
endmodule

module aggregateALL(clk,rst);//Instructions are assumed to be loaded pre
input clk,rst;
wire [2:0] aluOp;
wire [1:0] aluA,aluB,dataMemAddressSelect;
wire writeDataMem,writeRegSourceSelect,writeReg,instructJump,instructBranch,writeSP;
wire [3:0] flagout;//output of regfile aggregate
wire [15:0] A,B,Des;//output of regfile aggregate
wire [8:0] pcaddress;//output of pcupdate
wire [15:0] I;//output of imem
reg [15:0] IMdatain;//these two need be hard coded
reg writeInstructionMem;//need to redefine the rst of instruction memory
wire [3:0] flagin;
wire [7:0] spout;
wire [15:0] aluin;
wire [15:0] dataMemin;
wire isPOP;
ControlUnit CUuut(I,aluOp,aluA,aluB,dataMemAddressSelect,writeDataMem,writeRegSourceSelect,writeReg,instructJump,instructBranch,writeSP,isPOP);
PCUpdate PCuut(clk,rst,I,instructBranch,instructJump,flagin[2],Des,pcaddress);
InstructionMemory IMuut(pcaddress,I,IMdatain,clk,writeInstructionMem,rst);
aggregateRegFile RFuut(I[7:4],I[3:0],I[11:8],clk,rst,flagin,flagout,spout,aluin,dataMemin,A,B,Des,writeSP,writeReg,writeRegSourceSelect,isPOP);
aggregateALU ALUuut(aluA,aluB,aluOp,spout,A,I[7:4],B,Des,aluin,flagin);
aggregateDataMem DMuut(clk,rst,writeDataMem,dataMemAddressSelect,isPOP,B,dataMemin,I,A,spout);
initial begin
    writeInstructionMem = 1'b0;
    IMdatain = 16'b0;
end
endmodule

module PCUpdate(clk,rst,I,instructBranch,instructJump,zeroflag,beqaddress,pcaddress);
input [15:0] I;
input instructBranch, instructJump, zeroflag,rst,clk;
input [15:0] beqaddress;
output [8:0] pcaddress;
wire [8:0] addedpc;
wire [8:0] shortjump;//this can be left shifted or prefixed with zero depending on the kind of jump you want
wire [8:0] pcorjump;
wire [8:0] beqaddresstrimmed;
wire branchselection;
wire [8:0] pcnextaddress;
assign shortjump[7:0] = I[11:4];
assign shortjump[8] = 1'b0;//prefixed with zero
assign beqaddresstrimmed[8:0] = beqaddress[8:0];
and agate(branchselection,instructBranch,zeroflag);
PCAdder pcadd(pcaddress,addedpc);
mux9bit_2x1 selectjump(addedpc,shortjump,instructJump,pcorjump);//for use in pc aggregate module
mux9bit_2x1 selectbranch(pcorjump,beqaddresstrimmed,branchselection,pcnextaddress);
ProgramCounter pc(clk,rst,pcnextaddress,pcaddress);
endmodule

module aggregateDataMem(clk,rst,writeDataMem,dataMemAddressSelect,isPOP,datain,dataout,I,customload,stackaddress);
input clk,rst,writeDataMem;
input isPOP;
input [1:0] dataMemAddressSelect;
input [15:0] datain;
output [15:0] dataout;
input [15:0] I;
input [15:0] customload;
input [7:0] stackaddress;
wire [7:0] finaladdress;
wire [7:0] popnoaddone;
wire [7:0] popaddone = popnoaddone + 1;
mux8bit_4x1 selectaddress(I[7:0],I[11:4],stackaddress,customload[7:0],dataMemAddressSelect,popnoaddone);
mux8bit_2x1 forpop(popnoaddone,popaddone,isPOP,finaladdress);//fourth one is for custom instruction: load from register address
DataMemory dmem(finaladdress,dataout,datain,clk,writeDataMem,rst);
endmodule

module aggregateALU(aluA,aluB,aluOp,stackaddress,s1,shftamnt,s2,d,res,flags);
input [1:0] aluA,aluB;
input [2:0] aluOp;
input [7:0] stackaddress;
input [15:0] s1,s2,d;
input [3:0] shftamnt;
output [15:0] res;
output [3:0] flags;
wire [15:0] A,B;
wire [15:0] onefix;
wire [15:0] extendedstackaddress;
wire [15:0] extendedshftamnt;
assign onefix = 16'b1;
assign extendedstackaddress[7:0] = stackaddress;
assign extendedstackaddress[15:8] = 8'b0;
assign extendedshftamnt[15:4] = 12'b0;
assign extendedshftamnt[3:0] = shftamnt;
mux16bit_4x1 selA(s1,extendedstackaddress,extendedshftamnt,onefix,aluA,A);
mux16bit_4x1 selB(onefix,s2,d,onefix,aluB,B);
ALU aluUnit(aluOp,A,B,res,flags);
endmodule

module aggregateRegFile(s1,s2,d,clk,rst,flagin,flagout,spout,aluin,dataMemin,A,B,Des,writeSP,writeReg,writeRegSourceSelect,isPOP);//flag should always be written, don't need spin as we have aluin
input clk,rst,writeSP,writeReg,writeRegSourceSelect;
input [3:0] s1,s2,d,flagin;
input [15:0] aluin,dataMemin;
output [15:0] A,B,Des;
output [3:0] flagout;
output [7:0] spout;
wire [15:0] dataRegIn;
input isPOP;
mux16bit_2x1 muxuut(aluin,dataMemin,writeRegSourceSelect,dataRegIn);
RegisterFile rfuut(d,s1,s2,clk,rst,writeReg,dataRegIn,Des,A,B);
flags flaguut(flagin,flagout,clk,rst);
StackPointer spuut(clk,rst,writeSP,aluin[7:0],spout,isPOP);
endmodule

