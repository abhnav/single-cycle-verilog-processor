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
