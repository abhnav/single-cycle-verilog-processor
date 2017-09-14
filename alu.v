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
//module alutb();
//reg [15:0] a,b;
//reg [2:0] aluop;
//wire [3:0] flags;
//wire [15:0] res;
//ALU alup(aluop,a,b,res,flags);
//initial begin
    //$dumpfile("alu.vcd");
    //$dumpvars;
    //aluop = 3'b001;
    //a = 16'h1234;
    //b = 16'h000F;
    //#5 a = 16'h2342;
    //b = 16'h4222;
    //#10 $finish;
//end
//endmodule
