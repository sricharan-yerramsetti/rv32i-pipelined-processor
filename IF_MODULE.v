module IF_MODULE(
    input clk,
    input signed [31:0] imm,
    input [1:0] PC_SRC,
    input [31:0] result,
    output [31:0] inst, 
    output[31:0] pc_if       // fix 1
);
parameter START_ADDR = 0;
reg [31:0] pc = START_ADDR;
reg [7:0] IM[0:4095];             // fix 2

integer i;
initial begin
    for(i=0; i<4096; i=i+1) IM[i] = 8'h00;
    $readmemh("IM.hex", IM);
end

always @(posedge clk) begin
    case(PC_SRC)
        2'b00 : pc <= pc;
        2'b01 : pc <= pc + 4;
        2'b10 : pc <= pc + $signed(imm) - 4;   // fix 4
        2'b11 : pc <= result;
        default : pc <= pc + 4;
    endcase
end

assign inst = {IM[pc+3],IM[pc+2],IM[pc+1],IM[pc]};         // fix 3
assign pc_if = pc;
endmodule