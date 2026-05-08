module alu_unit(A, B, control_in, alu_result, zero);
    input [31:0] A, B;
    input [3:0] control_in;
    output reg zero;
    output reg [31:0] alu_result;

    always @(*) begin // Fix: Use modern sensitivity wildcard
        case(control_in)
            4'b0000: alu_result = A & B;
            4'b0001: alu_result = A | B;
            4'b0010: alu_result = A + B;
            4'b0110: alu_result = A - B;
            default: alu_result = 32'b0;
        endcase
        zero = (alu_result == 32'b0); // Fix: Simplified zero flag logic
    end
endmodule

module alu_unit(A,B,control_in,alu_result,zero);
input  [31:0] A,B;
input  [3:0]control_in;
output reg zero;
output reg [31:0] alu_result;
always @(control_in or A or B) 
begin
    case(control_in)
    4'b0000:begin zero <= 0;alu_result <= A & B;end
    4'b0001:begin zero <= 0;alu_result <= A | B;end
    4'b0010:begin zero <= 0;alu_result <= A + B;end
    4'b0110:begin if(A==B)zero <= 1;else zero <= 0;alu_result <= A - B;end
    endcase  
    zero = (alu_result == 32'b0); 
end
endmodule



//-------------------------------------------------------------------------------------------------
// addi x7, x1, 10
    memory[4] = 32'b000000001010_00001_000_00111_0010011;


    