module FORWARDING_UNIT(
    input[4:0] ID_EX_rs1,
    input[4:0] ID_EX_rs2,
    input[4:0] MEM_WB_rd,
    input MEM_WB_WE,
    input[31:0] MEM_WB_result,
    input[4:0] EX_MEM_rd,
    input EX_MEM_WE,
    input[31:0] EX_MEM_result,
    input[1:0] OP_1,
    input[1:0] OP_2,
    output reg FORWARD_A,
    output reg FORWARD_B,
    output reg[31:0] foredata_A,
    output reg[31:0] foredata_B
);

always@(*) begin


    if((OP_1 == 2'b00)&&(EX_MEM_WE == 1'b1)&&(EX_MEM_rd != 5'b00000)&&(EX_MEM_rd == ID_EX_rs1)) begin
            FORWARD_A = 1'b1;
            foredata_A = EX_MEM_result;
    end

    else if((OP_1 == 2'b00)&&(MEM_WB_WE == 1'b1)&&(MEM_WB_rd != 5'b00000)&&(MEM_WB_rd == ID_EX_rs1)) begin
            FORWARD_A = 1'b1;
            foredata_A = MEM_WB_result;
    end

    else begin
            FORWARD_A = 1'b0;
            foredata_A = 0;
    end




    if((OP_2 == 2'b00)&&(EX_MEM_WE == 1'b1)&&(EX_MEM_rd != 5'b00000)&&(EX_MEM_rd == ID_EX_rs2)) begin
            FORWARD_B = 1'b1;
            foredata_B = EX_MEM_result;
    end

    else if((OP_2 == 2'b00)&&(MEM_WB_WE == 1'b1)&&(MEM_WB_rd != 5'b00000)&&(MEM_WB_rd == ID_EX_rs2)) begin
            FORWARD_B = 1'b1;
            foredata_B = MEM_WB_result;
    end

    else begin
            FORWARD_B = 1'b0;
            foredata_B = 0;
    end


end


endmodule