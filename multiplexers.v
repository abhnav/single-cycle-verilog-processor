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
