module HAZARD_DETECTION_UNIT(
    input[4:0] IF_ID_rs1,
    input[4:0] IF_ID_rs2,
    input ID_EX_MEM_READ,
    input[4:0] ID_EX_rd,
    output reg HAZARD
);

always@(*) begin

    if((ID_EX_MEM_READ == 1'b1)&&((IF_ID_rs1 == ID_EX_rd)||(IF_ID_rs2 == ID_EX_rd))) begin
        HAZARD = 1'b1;
    end

    else begin
        HAZARD = 1'b0;
    end

end

endmodule