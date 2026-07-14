
module top_module(
    input clk
);

wire[31:0] imm_id;
wire[31:0] result_alu;   // IF_MODULE
wire[1:0] PC_SRC;

wire FREEZE;
wire NOP_IF_ID;
wire [31:0] inst_if; // IF_ID_LATCH
wire[31:0] pc_if;

wire[4:0] rs1_id;
wire[4:0] rs2_id;      //  REG_BANK
wire WE_wb;
wire[4:0] rd_wb;
wire[31:0] rd_data_wb;

wire UNSIGNED;      // SIGN_EXTEND
wire[3:0] TYPE;

wire[31:0] inst_id;
wire HAZARD;        //CONTROLLER

// FORWARDING_UNIT


    

// HARZARD_DETECTING_UNIT

wire NOP_ID_EX;
wire [31:0] pc_id;
wire [4:0] rd_id;       //ID_EX_LATCH
wire MEM_WRITE_id;
wire [3:0] ALU_OP_id;
wire [1:0] OP_1_id;
wire [1:0] OP_2_id;
wire WE_id;
wire [31:0] rs1_data_id;
wire [31:0] rs2_data_id;
wire MEM_READ_id;
wire MEM_WRITE_SEL_id;

wire[31:0] rs1_data_ex;
wire[31:0] pc_ex;
wire[31:0] rs2_data_ex;
wire[31:0] imm_ex;
wire[1:0] OP_1_ex;         // ALU
wire[1:0] OP_2_ex;
wire[31:0] foredata_A;
wire[31:0] foredata_B;
wire FORWARD_A;
wire FORWARD_B;
wire[3:0] ALU_OP_ex;
wire[4:0] rs1_ex;
wire[4:0] rs2_ex;
wire[31:0] jump_addr;

wire[4:0] rd_ex;
wire MEM_WRITE_ex;
wire WE_ex;             // EX_MEM_LATCH
wire MEM_READ_ex;
wire MEM_WRITE_SEL_ex;

wire[31:0] rs2_data_mem;
wire[31:0] result_mem;        // MEM
wire MEM_READ_mem;
wire MEM_WRITE_mem;

wire WE_mem;
wire[4:0] rd_mem;
wire[31:0] mem_data_mem;
wire MEM_WRITE_SEL_mem;

wire[31:0] result_wb;
wire[31:0] mem_data_wb;    // WB
wire MEM_WRITE_SEL_wb;


wire [31:0] rs2_data_fwd;


IF_MODULE IF_MODULE_INST(
    .clk(clk),
    .imm(imm_id),
    .PC_SRC(PC_SRC),        
    .result(jump_addr),
    .inst(inst_if),
    .pc_if(pc_if)
);

CONTROLLER CONTROLLER_INST(
    .clk(clk),
    .HAZARD(HAZARD),
    .inst(inst_id),
    .result(result_alu),
    .TYPE(TYPE),
    .MEM_READ(MEM_READ_id),
    .PC_SRC(PC_SRC),
    .UNSIGNED(UNSIGNED),
    .NOP_IF_ID(NOP_IF_ID),
    .OP_1(OP_1_id),
    .OP_2(OP_2_id),
    .MEM_WRITE(MEM_WRITE_id),
    .WE(WE_id),
    .NOP_ID_EX(NOP_ID_EX),
    .FREEZE(FREEZE),
    .ALU_OP(ALU_OP_id),
    .MEM_WRITE_SEL(MEM_WRITE_SEL_id)
);

REG_BANK REG_BANK_INST(
    .clk(clk),
    .rs1(rs1_id),
    .rs2(rs2_id),
    .rd(rd_wb),
    .rd_data(rd_data_wb),
    .WE(WE_wb),
    .rs1_data(rs1_data_id),
    .rs2_data(rs2_data_id)
);

SIGN_EXTEND SIGN_EXTEND_INST(
    .inst_part(inst_id[31:7]),
    .TYPE(TYPE),
    .UNSIGNED(UNSIGNED),
    .imm(imm_id)
);

ALU ALU_INST(
    .rs1_data(rs1_data_ex),
    .pc(pc_ex),
    .rs2_data(rs2_data_ex),
    .imm(imm_ex),
    .OP_1(OP_1_ex),
    .OP_2(OP_2_ex),
    .foredata_A(foredata_A),
    .foredata_B(foredata_B),
    .FORWARD_A(FORWARD_A),
    .FORWARD_B(FORWARD_B),
    .ALU_OP(ALU_OP_ex),
    .result(result_alu),
    .jump_addr(jump_addr)
);

MEM MEM_INST(
    .clk(clk),
    .MEM_READ(MEM_READ_mem),
    .rs2_data(rs2_data_mem),
    .addr(result_mem),
    .MEM_WRITE(MEM_WRITE_mem),
    .mem_data(mem_data_mem)
);

WB WB_INST(
    .result(result_wb),
    .mem_data(mem_data_wb),
    .MEM_WRITE_SEL(MEM_WRITE_SEL_wb),
    .rd_data(rd_data_wb)
);

FORWARDING_UNIT FORWARDING_UNIT_INST(
    .ID_EX_rs1(rs1_ex),
    .ID_EX_rs2(rs2_ex),
    .MEM_WB_rd(rd_wb),
    .MEM_WB_WE(WE_wb),
    .MEM_WB_result(rd_data_wb),
    .EX_MEM_rd(rd_mem),
    .EX_MEM_WE(WE_mem),
    .EX_MEM_result(result_mem),
    .FORWARD_A(FORWARD_A),
    .FORWARD_B(FORWARD_B),
    .foredata_A(foredata_A),
    .foredata_B(foredata_B),
    .OP_1(OP_1_ex),
    .OP_2(OP_2_ex)
);

HAZARD_DETECTION_UNIT HAZARD_DETECTION_UNIT_INST(
    .IF_ID_rs1(rs1_id),
    .IF_ID_rs2(rs2_id),
    .ID_EX_MEM_READ(MEM_READ_ex),
    .ID_EX_rd(rd_ex),
    .HAZARD(HAZARD)
);

IF_ID IF_ID_INST(
    .clk(clk),
    .FREEZE(FREEZE),
    .NOP_IF_ID(NOP_IF_ID),
    .pc_in(pc_if),
    .inst_in(inst_if),
    .pc(pc_id),
    .inst(inst_id)
);

ID_EX ID_EX_INST(
    .clk(clk),
    .NOP_ID_EX(NOP_ID_EX),
    .imm_in(imm_id),
    .pc_in(pc_id),
    .rd_in(rd_id),
    .MEM_WRITE_in(MEM_WRITE_id),
    .ALU_OP_in(ALU_OP_id),
    .OP_1_in(OP_1_id),         
    .OP_2_in(OP_2_id),         
    .WE_in(WE_id),
    .rs1_data_in(rs1_data_id),
    .rs2_data_in(rs2_data_id),
    .rs1_in(rs1_id),
    .rs2_in(rs2_id),
    .MEM_READ_in(MEM_READ_id),
    .MEM_WRITE_SEL_in(MEM_WRITE_SEL_id),
    .imm(imm_ex),
    .pc(pc_ex),
    .rd(rd_ex),
    .MEM_WRITE(MEM_WRITE_ex),
    .ALU_OP(ALU_OP_ex),
    .OP_1(OP_1_ex),
    .OP_2(OP_2_ex),
    .WE(WE_ex),
    .rs1_data(rs1_data_ex),
    .rs2_data(rs2_data_ex),
    .rs1(rs1_ex),
    .rs2(rs2_ex),
    .MEM_READ(MEM_READ_ex),
    .MEM_WRITE_SEL(MEM_WRITE_SEL_ex)
);

EX_MEM EX_MEM_INST(
    .clk(clk),
    .rd_in(rd_ex),
    .result_in(result_alu),
    .MEM_WRITE_in(MEM_WRITE_ex),
    .WE_in(WE_ex),
    .rs2_data_in(rs2_data_fwd),
    .MEM_READ_in(MEM_READ_ex),
    .MEM_WRITE_SEL_in(MEM_WRITE_SEL_ex),
    .rd(rd_mem),
    .result(result_mem),
    .MEM_WRITE(MEM_WRITE_mem),
    .WE(WE_mem),
    .rs2_data(rs2_data_mem),
    .MEM_READ(MEM_READ_mem),
    .MEM_WRITE_SEL(MEM_WRITE_SEL_mem)
);

MEM_WB MEM_WB_INST(
    .clk(clk),
    .WE_in(WE_mem),
    .rd_in(rd_mem),
    .result_in(result_mem),
    .mem_data_in(mem_data_mem),
    .MEM_WRITE_SEL_in(MEM_WRITE_SEL_mem),
    .WE(WE_wb),
    .rd(rd_wb),
    .result(result_wb),
    .mem_data(mem_data_wb),
    .MEM_WRITE_SEL(MEM_WRITE_SEL_wb)
);


assign rs1_id = inst_id[19:15];
assign rs2_id = inst_id[24:20];
assign rd_id  = inst_id[11:7];
assign rs2_data_fwd = (WE_mem && rd_mem != 5'b0 && rd_mem == rs2_ex) ? result_mem :rs2_data_ex;




endmodule
