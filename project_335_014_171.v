//Abhinav gupta 2014A7PS335P
//Mandeep 2014A3PS014P
//Shashank R 2014A3PS171P
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
module PCAdder(pc,pcout);
input [8:0] pc;
output [8:0] pcout;
assign pcout = pc+1;
endmodule
module mux8bit_4x1(a,b,c,d,sel,out);//fourth one is for custom instruction: load from register address
output reg [7:0] out;
input [1:0] sel;
input [7:0] a,b,c,d;
always@(*) begin
    case(sel)
        2'b00:out = a;
        2'b01:out = b;
        2'b10:out = c;
        2'b11:out = d;
    endcase;
end
endmodule

module mux8bit_2x1(a,b,sel,out);//fourth one is for custom instruction: load from register address
output reg [7:0] out;
input sel;
input [7:0] a,b;
always@(*) begin
    case(sel)
        1'b0:out = a;
        1'b1:out = b;
    endcase;
end
endmodule

module mux9bit_2x1(a,b,sel,out);//for use in pc aggregate module
output reg [8:0] out;
input sel;
input [8:0] a,b;
always@(*) begin
    case(sel)
        1'b0:out = a;
        1'b1:out = b;
    endcase;
end
endmodule

module mux16bit_2x1(a,b,sel,out);
output reg [15:0] out;
input sel;
input [15:0] a,b;
always@(*) begin
    case(sel)
        1'b0:out = a;
        1'b1:out = b;
    endcase;
end
endmodule

module mux16bit_4x1(a,b,c,d,sel,out);
output reg [15:0] out;
input [1:0] sel;
input [15:0] a,b,c,d;
always@(*) begin
    case(sel)
        2'b00:out = a;
        2'b01:out = b;
        2'b10:out = c;
        2'b11:out = d;
    endcase
end
endmodule
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
        
          


module ALUControl(I,aluOp);//opcode is I[15:12]
output [2:0] aluOp;
input [15:0] I;
assign aluOp[2] = ~I[15] & ~I[14] & I[13] & I[12];//last two bits of opcode are 1
assign aluOp[1] = ~I[15] & ~I[14] & I[13] & ~I[12] | ~I[15] & I[14] & ~I[13] & ~I[12] | ~I[15] & ~I[14] & I[13] & I[12] & ~I[3] & ~I[2] & I[1];
assign aluOp[0] = ~I[15] & ~I[14] & ~I[13] & I[12] | ~I[15] & I[14] & ~I[13] & ~I[12] | ~I[15] & ~I[14] & I[13] & I[12] & ~I[3] & ~I[2] & I[0] | ~I[15] & I[14] & I[13] & ~I[12] | I[15] & I[14] & ~I[13] & I[12];//last one is for beq which requires subtraction
endmodule

module ControlUnit(I,aluOp,aluA,aluB,dataMemAddressSelect,writeDataMem,writeRegSourceSelect,writeReg,instructJump,instructBranch,writeSP,isPOP);
input [15:0] I;
output [2:0] aluOp;
output reg [1:0] aluA,aluB;
output reg [1:0] dataMemAddressSelect;
output reg writeDataMem;
output reg writeRegSourceSelect;
output reg writeReg;
output reg instructJump;
output reg instructBranch;
output reg writeSP;
output reg isPOP;
wire [7:0] It;
assign It[7:4] = I[15:12];
assign It[3:0] = I[3:0];
ALUControl alucontroller(I,aluOp);
always@(*) begin
casez(It)
8'b0000????: begin//add		//note that there is no contention for which register to write at
aluA = 2'b00;			//it is always rd
aluB = 2'b01;
writeDataMem = 1'b0;
dataMemAddressSelect = 2'b00;
writeReg = 1'b1;
writeRegSourceSelect = 1'b0;
instructBranch = 1'b0;
instructJump = 1'b0;
writeSP = 1'b0;
isPOP = 1'b0;
end
8'b0001????: begin//sub
aluA = 2'b00;			//it is always rd
aluB = 2'b01;
writeDataMem = 1'b0;
dataMemAddressSelect = 2'b00;
writeReg = 1'b1;
writeRegSourceSelect = 1'b0;	//select data from alu to write to register
instructBranch = 1'b0;
instructJump = 1'b0;
writeSP = 1'b0;
isPOP = 1'b0;
end
8'b0010????: begin//nand
aluA = 2'b00;			//it is always rd
aluB = 2'b01;
writeDataMem = 1'b0;
dataMemAddressSelect = 2'b00;
writeReg = 1'b1;
writeRegSourceSelect = 1'b0;	//select data from alu to write to register
instructBranch = 1'b0;
instructJump = 1'b0;
writeSP = 1'b0;
isPOP = 1'b0;
end
8'b0100????: begin//nor
aluA = 2'b00;			//it is always rd
aluB = 2'b01;
writeDataMem = 1'b0;
dataMemAddressSelect = 2'b00;
writeReg = 1'b1;
writeRegSourceSelect = 1'b0;	//select data from alu to write to register
instructBranch = 1'b0;
instructJump = 1'b0;
writeSP = 1'b0;
isPOP = 1'b0;
end
8'b00110000: begin//neg
aluA = 2'b00;//s1
aluB = 2'b00;//don't care
writeDataMem = 1'b0;
dataMemAddressSelect = 2'b00;
writeReg = 1'b1;
writeRegSourceSelect = 1'b0;	//select data from alu to write to register
instructBranch = 1'b0;
instructJump = 1'b0;
writeSP = 1'b0;
isPOP = 1'b0;
end
8'b00110001: begin//sar
aluA = 2'b10;//4 bits of instruction s1 as immediate shift amount
aluB = 2'b10;//use rd as second alu operand
writeDataMem = 1'b0;
dataMemAddressSelect = 2'b00;
writeReg = 1'b1;
writeRegSourceSelect = 1'b0;	//select data from alu to write to register
instructBranch = 1'b0;
instructJump = 1'b0;
writeSP = 1'b0;
isPOP = 1'b0;
end
8'b00110010: begin//shr
aluA = 2'b10;//4 bits of instruction s1 as immediate shift amount
aluB = 2'b10;//use rd as second alu operand
writeDataMem = 1'b0;
dataMemAddressSelect = 2'b00;
writeReg = 1'b1;
writeRegSourceSelect = 1'b0;	//select data from alu to write to register
instructBranch = 1'b0;
instructJump = 1'b0;
writeSP = 1'b0;
isPOP = 1'b0;
end
8'b00110011: begin//shl
aluA = 2'b10;//4 bits of instruction s1 as immediate shift amount
aluB = 2'b10;//use rd as second alu operand
writeDataMem = 1'b0;
dataMemAddressSelect = 2'b00;
writeReg = 1'b1;
writeRegSourceSelect = 1'b0;	//select data from alu to write to register
instructBranch = 1'b0;
instructJump = 1'b0;
writeSP = 1'b0;
isPOP = 1'b0;
end
8'b1000????:begin//lw
aluA = 2'b00;//alu is don't care
aluB = 2'b00;
writeDataMem = 1'b0;
dataMemAddressSelect = 2'b00;//use address supplied by load word format
writeReg = 1'b1;
writeRegSourceSelect = 1'b1;
instructBranch = 1'b0;
instructJump = 1'b0;
writeSP = 1'b0;
isPOP = 1'b0;
end
8'b1001????:begin//sw
aluA = 2'b00;//alu is don't care
aluB = 2'b00;
writeDataMem = 1'b1;//write data to memory
dataMemAddressSelect = 2'b01;//use address supplied by store word format
writeReg = 1'b0;//nothing to write to reg
writeRegSourceSelect = 1'b0;//don't care
instructBranch = 1'b0;
instructJump = 1'b0;
writeSP = 1'b0;
isPOP = 1'b0;
end
8'b1110????: begin//pop, similar to lw
aluA = 2'b01;//sp increment
aluB = 2'b00;// increment by 1 (extend to 16 bits)
writeDataMem = 1'b0;
dataMemAddressSelect = 2'b10;//use address supplied by sp 
writeReg = 1'b1;
writeRegSourceSelect = 1'b1;//memory
instructBranch = 1'b0;
instructJump = 1'b0;
writeSP = 1'b1;//write new value to sp
isPOP = 1'b1;
end
8'b0110????: begin//push, similar to sw
aluA = 2'b01;//sp decrement
aluB = 2'b00;//by one
writeDataMem = 1'b1;//write data to memory
dataMemAddressSelect = 2'b10;//use address supplied by sp
writeReg = 1'b0;//nothing to write to reg
writeRegSourceSelect = 1'b0;//don't care
instructBranch = 1'b0;
instructJump = 1'b0;
writeSP = 1'b1;
isPOP = 1'b0;
end
8'b1111????: begin//custom load word
aluA = 2'b00;
aluB = 2'b00;
writeDataMem = 1'b0;
dataMemAddressSelect = 2'b11;//custom load address supplied by s1 read (truncate to 8 bits)
writeReg = 1'b1;
writeRegSourceSelect = 1'b1;//memory
instructBranch = 1'b0;
instructJump = 1'b0;
writeSP = 1'b0;
isPOP = 1'b0;
end
8'b1101????: begin//beq
aluA = 2'b00;//s1 subtract
aluB = 2'b01;//s2
writeDataMem = 1'b0;
dataMemAddressSelect = 2'b00;
writeReg = 1'b0;
writeRegSourceSelect = 1'b0;
instructBranch = 1'b1;
instructJump = 1'b0;
writeSP = 1'b0;
isPOP = 1'b0;
end
8'b1100????: begin//jmp
aluA = 2'b00;//don't care
aluB = 2'b00;
writeDataMem = 1'b0;
dataMemAddressSelect = 2'b00;
writeReg = 1'b0;
writeRegSourceSelect = 1'b0;
instructBranch = 1'b0;
instructJump = 1'b1;
writeSP = 1'b0;
isPOP = 1'b0;
end
endcase;
end
endmodule
module ALU(ALUOp,A,B,res,flags);
input [2:0] ALUOp;
input [15:0] A,B;
output reg [15:0] res;
reg carry;
reg [15:0] temp;
output reg [3:0] flags;//O,Z,S,C
initial begin
    carry = 1'b0;
end
always@(*) begin
    case(ALUOp) 
        3'b000: begin//addition
            {carry,res} = A + B;
            if(res == 0)
                flags[2] = 1;
            else
                flags[2] = 0;
            flags[1] = res[15];
            flags[0] = carry;
            flags[3] = A[15]&B[15]&~res[15] | ~A[15]&~B[15]&res[15];
        end
        3'b001: begin//subtraction
            $display("temp value is %b\n",temp);
            $display("b is %b\n",B);
            $display("a is %b\n",A);
            temp = -B;
            {carry,res} = A + temp;
            if(res == 0)
                flags[2] = 1;
            else
                flags[2] = 0;
            flags[1] = res[15];
            flags[0] = carry;
            flags[3] = A[15]&temp[15]&~res[15] | ~A[15]&~temp[15]&res[15];
        end
        3'b010: begin//NAND
            res = A ~& B;
            flags[0] = 0;
            flags[3] = 0;
            flags[1] = res[15];
            if(res == 0)
                flags[2] = 1;
            else
                flags[2] = 0;
        end
        3'b011: begin//NOR
            res = A ~| B;
            flags[0] = 0;
            flags[3] = 0;
            flags[1] = res[15];
            if(res == 0)
                flags[2] = 1;
            else
                flags[2] = 0;
        end
        3'b100: begin//NEG
            res = -A;
            flags[0] = 0;
            flags[1] = res[15];
            if(res == 0)
                flags[2] = 1;
            else
                flags[2] = 0;
            if(res[15] == A[15] && res != 0)//when signs are same but none is zero
                flags[3] = 1;
            else
                flags[3] = 0;
        end
        3'b101: begin//SAR, A contains the shift amount 0 extended to 16 bits, it will always be < 16
            res = $signed(B) >>> A;
            flags[1] = res[15];
            if(res == 0)
                flags[2] = 1;
            else
                flags[2] = 0;
            if(A == 0)
                flags[0] = 0;
            else
                flags[0] = B[A-1];
            flags[3] = 0;//overflow flag cleared for sar
        end
        3'b110: begin//SHR
            res = B >> A;
            flags[1] = res[15];
            if(res == 0)
                flags[2] = 1;
            else
                flags[2] = 0;
            if(A == 0)
                flags[0] = 0;
            else
                flags[0] = B[A-1];
            flags[3] = B[15];//store the sign of original operand
        end
        3'b111: begin//SHL
            res = B << A;
            flags[1] = res[15];
            if(res == 0)
                flags[2] = 1;
            else
                flags[2] = 0;
            if(A == 0)
                flags[0] = 0;
            else
                flags[0] = B[16-A];
            if(A == 1) begin
                if(B[15] == B[14])
                    flags[3] = 0;
                else
                    flags[3] = 1;
            end
            else
                flags[3] = 0;//overflow not set if amnt > 1
        end
    endcase;
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

