module WB(
    input[31:0] result,
    input[31:0] mem_data,
    input MEM_WRITE_SEL,
    output[31:0] rd_data
);

assign rd_data = (MEM_WRITE_SEL == 1'b1)?mem_data:result;


endmodule