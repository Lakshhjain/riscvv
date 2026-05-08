module program_counter(clk,reset,pc_in,pc_out);
    input clk, reset; 
    input [31:0] pc_in; 
    output reg [31:0] pc_out;
always @(posedge clk or posedge reset) 
begin
    if (reset)
        pc_out <= 32'b0; 
    else
        pc_out <= pc_in;    
    
end     
endmodule

module pc_plus4(from_pc,to_pc);
input [31:0] from_pc; 
output [31:0] to_pc;
assign to_pc = 4 + from_pc;
endmodule

module instruction_memory(read_addr, instruction_out);
input [31:0] read_addr;
integer i;
output reg [31:0] instruction_out;
reg [31:0] memory [63:0];
initial begin
    // Initialize all to 0
    for (i = 0; i < 64; i = i + 1)
        memory[i] = 32'b0;
    // add x3, x1, x2   → x3 = x1 + x2
    memory[0] = 32'b0000000_00010_00001_000_00011_0110011;
    // sub x4, x1, x2   → x4 = x1 - x2
    memory[1] = 32'b0100000_00010_00001_000_00100_0110011;
    // and x5, x1, x2
    memory[2] = 32'b0000000_00010_00001_111_00101_0110011;
    // or x6, x1, x2
    memory[3] = 32'b0000000_00010_00001_110_00110_0110011;
    
end
always @(*) begin
    instruction_out = memory[read_addr[7:2]];
end

endmodule

module registerfile(clk,reset,regwrite,rs1,rs2,rd,write_data,read_data1,read_data2);
input clk, reset, regwrite;
input [4:0] rs1, rs2, rd;       
input [31:0] write_data;
output  [31:0] read_data1, read_data2;
integer k;
reg [31:0] registers [31:0];
always@(posedge clk or posedge reset)
begin
    if(reset)
    begin
        for(k=0; k<32; k=k+1)
            registers[k] <= 32'b0;
        registers[1] <= 32'd10; // x1 = 10
        registers[2] <= 32'd5;
    end
    else if(regwrite && rd != 5'b0)
    begin
        registers[rd] <= write_data;
    end
end
assign read_data1 = registers[rs1];
assign read_data2 = registers[rs2];

endmodule

module immgen (opcode,instruction_out,immediate_out);
input [6:0] opcode;
input [31:0] instruction_out;
output reg [31:0] immediate_out;
always @(*) 
begin
    case (opcode)
        7'b0000011: immediate_out = {{20{instruction_out[31]}}, instruction_out[31:20]}; 
        7'b0100011: immediate_out = {{20{instruction_out[31]}}, instruction_out[31:25], instruction_out[11:7]};
        
        default:    immediate_out = 32'b0;
    endcase
end    
endmodule

module controlunit  (opcode,branch,memread,memtoreg,aluop,memwrite,alusrc,regwrite);
input [6:0] opcode;
output reg branch,memread,memtoreg,memwrite,alusrc,regwrite;
output reg [1:0]aluop;
always @(*) 
begin
    case (opcode)
        7'b0110011:{alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop}= 8'b001000_10; 
        7'b0000011:{alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop}= 8'b111100_00; 
        7'b0100011:{alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop}= 8'b100010_00;
        7'b0010011:{alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop}= 8'b101000_11; 
        default:   {alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop}= 8'b000000_00; 
    endcase
end    
endmodule

module alu_unit(A, B, control_in, alu_result, zero);
    input [31:0] A, B;
    input [3:0] control_in;
    output reg zero;
    output reg [31:0] alu_result;

    always @(*) begin 
        case(control_in)
            4'b0000: alu_result = A & B;
            4'b0001: alu_result = A | B;
            4'b0010: alu_result = A + B;
            4'b0110: alu_result = A - B;
            default: alu_result = 32'b0;
        endcase
        zero = (alu_result == 32'b0); 
    end
endmodule

module alucontrol (aluop,func7,func3,control_out);
input  func7;
input [2:0] func3;
input [1:0] aluop;
output reg [3:0] control_out;
always @(*) 
begin
    case ({aluop,func7,func3})
    6'b00_0_000:control_out = 4'b0010;        
    6'b01_0_000:control_out = 4'b0110;        
    6'b10_0_000:control_out = 4'b0010;        
    6'b10_1_000:control_out = 4'b0110;        
    6'b10_0_111:control_out = 4'b0000;        
    6'b10_0_110:control_out = 4'b0001;  
    6'b11_0_000:control_out = 4'b0010;
    default: control_out = 4'b0000; 
    endcase
end    
endmodule

module mux1 (sel1,a1,b1,mux1_out);
input sel1;
input [31:0] a1,b1;
output [31:0] mux1_out;
assign mux1_out = (sel1==1'b0) ? a1 : b1; 
endmodule

module mux2 (sel2,a2,b2,mux2_out);
input sel2;
input [31:0] a2,b2;
output [31:0] mux2_out;
assign mux2_out = (sel2==1'b0) ? a2 : b2; 
endmodule

module mux3 (sel3,a3,b3,mux3_out);
input sel3;
input [31:0] a3,b3;
output [31:0] mux3_out;
assign mux3_out = (sel3==1'b0) ? a3 : b3; 
endmodule

module adder (in_1,in_2,sum_out);
input [31:0] in_1, in_2;
output [31:0] sum_out;
assign sum_out = in_1 + in_2;
endmodule

module datamemory(clk,reset,memread,memwrite,write_data,read_data,read_addrss);
input  clk,reset,memread,memwrite;
input [31:0] read_addrss,write_data;
output [31:0] read_data;
reg[31:0] d_mem[63:0];
integer k;
always @(posedge clk or posedge reset ) 
begin
if (reset)
begin
    for(k=0;k<64;k=k+1) begin
        d_mem[k]=32'b00;
    end
else if (memwrite) begin
    d_mem[read_addrss]<=write_data;
    end    
end
end
assign read_data =(memread)? d_mem[read_addrss[7:2]]:32'b00;
endmodule

module andlogic (branch,zero,and_out);
input  branch,zero;
output and_out;
assign and_out= branch & zero;     
endmodule

module top_module(clk, reset);
input clk, reset;

// -------------------- WIRES --------------------

wire [31:0] pc_current, pc_next, pc_plus4_out;
wire [31:0] instruction;
wire [31:0] read_data1, read_data2, write_data;
wire [31:0] imm_out;
// Control Signals
wire branch, memread, memtoreg, memwrite, alusrc, regwrite;
wire [1:0] aluop;
wire [31:0] alu_in2, alu_result;
wire zero;
wire [3:0] alu_control_out;
wire [31:0] shifted_imm;        // imm_out << 1  (shift block in diagram)
wire [31:0] branch_target;      // PC + shifted immediate
wire and_out;   
// -------------------- MODULE INSTANTIATIONS --------------------

// PC
program_counter PC (
    .clk(clk),
    .reset(reset),
    .pc_in(pc_next),
    .pc_out(pc_current)
);

// PC + 4
pc_plus4 PC4 (
    .from_pc(pc_current),
    .to_pc(pc_plus4_out)
);
assign pc_next = pc_plus4_out;

// Instruction Memory
instruction_memory IM (
    .read_addr(pc_current),
    .instruction_out(instruction)
);

// Control Unit
controlunit CU (
    .opcode(instruction[6:0]),
    .branch(branch),
    .memread(memread),
    .memtoreg(memtoreg),
    .aluop(aluop),
    .memwrite(memwrite),
    .alusrc(alusrc),
    .regwrite(regwrite)
);

// Register File
registerfile RF (
    .clk(clk),
    .reset(reset),
    .regwrite(regwrite),
    .rs1(instruction[19:15]),
    .rs2(instruction[24:20]),
    .rd(instruction[11:7]),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

// Immediate Generator
immgen IG (
    .opcode(instruction[6:0]),
    .instruction_out(instruction),
    .immediate_out(imm_out)
);
// SHIFT LEFT 1 ) 
assign shifted_imm = imm_out << 1;

// BRANCH TARGET ADDER 
adder BRANCH_ADDER (
.in_1(pc_current), 
.in_2(shifted_imm), 
.sum_out(branch_target)
);

// AND GATE (branch & zero → PC select) 
andlogic AND_GATE (
.branch(branch), 
.zero(zero), 
.and_out(and_out)
);

// PC-SELECT MUX (Mux0/1 at top-right of diagram) 
mux3 PC_MUX (
.sel3(and_out),
.a3(pc_plus4_out),    // sel=0 → PC+4 (no branch)
.b3(branch_target),   // sel=1 → branch target
.mux3_out(pc_next)
);

// ALU Control
alucontrol ALUCTRL (
.   aluop(aluop),
.func7(instruction[30]),
.func3(instruction[14:12]),
.control_out(alu_control_out)
);

// ALU MUX (select between register and immediate)
mux1 ALU_SRC_MUX (
.sel1(alusrc),
.a1(read_data2),
.b1(imm_out),
.mux1_out(alu_in2)
);

// ALU
alu_unit ALU (
.A(read_data1),
.B(alu_in2),
.control_in(alu_control_out),
.alu_result(alu_result),
.zero(zero)
);
// ── DATA MEMORY ────────────────────────────────────────────
datamemory DM (
.clk(clk), 
.reset(reset),
.memread(memread), 
.memwrite(memwrite),
.read_addrss(alu_result),   // ALU result is the address
.write_data(read_data2),    // rs2 is the store data
.read_data(read_data)
);
// Write-back MUX (no data memory yet → just ALU)
mux2 WB_MUX (
.sel2(memtoreg),
.a2(alu_result),
.b2(read_data),   // placeholder (no data memory yet)
.mux2_out(write_data)
);

endmodule