module PCAdder(pc,pcout);
input [8:0] pc;
output [8:0] pcout;
assign pcout = pc+1;
endmodule
