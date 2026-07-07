module ID_EX(
    input clk,
    input NOP_ID_EX,
    input [31:0] imm_in,
    input [31:0] pc_in,
    input [4:0] rd_in,
    input MEM_WRITE_in,
    input [3:0] ALU_OP_in,
    input [1:0] OP_1_in,
    input [1:0] OP_2_in,
    input WE_in,
    input [31:0] rs1_data_in,
    input [31:0] rs2_data_in,
    input [4:0] rs1_in,
    input [4:0] rs2_in,
    input MEM_READ_in,
    input MEM_WRITE_SEL_in,
    output reg [31:0] imm,
    output reg [31:0] pc,
    output reg [4:0] rd,
    output reg MEM_WRITE,
    output reg [3:0] ALU_OP,
    output reg [1:0] OP_1,
    output reg [1:0] OP_2,
    output reg WE,
    output reg [31:0] rs1_data,
    output reg [31:0] rs2_data,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg MEM_READ,
    output reg MEM_WRITE_SEL
);


always@(posedge clk) begin

    if((NOP_ID_EX == 1'b1)) begin
        imm <= 0;
        pc <= pc_in;
        rd <= 0;
        MEM_WRITE <= 0;
        ALU_OP <= 4'b0000;
        OP_1 <= 2'b00;
        OP_2 <= 2'b10;
        WE <= 1'b0;
        rs1_data <= 0;
        rs2_data <= 0;
        rs1 <= 0;
        rs2 <= 0;
        MEM_READ <= 0;
        MEM_WRITE_SEL <= 0;

    end

    else begin
        imm <= imm_in;
        pc <= pc_in;
        rd <= rd_in;
        MEM_WRITE <= MEM_WRITE_in;
        ALU_OP <= ALU_OP_in;
        OP_1 <= OP_1_in;
        OP_2 <= OP_2_in;
        WE <= WE_in;
        rs1_data <= rs1_data_in;
        rs2_data <= rs2_data_in;
        rs1 <= rs1_in;
        rs2 <= rs2_in;
        MEM_READ <= MEM_READ_in;
        MEM_WRITE_SEL <= MEM_WRITE_SEL_in;

    end




end


endmodule