module MEM_WB(
    input clk,
    input WE_in,
    input[4:0] rd_in,
    input[31:0] result_in,
    input[31:0] mem_data_in,
    input MEM_WRITE_SEL_in,
    output reg WE,
    output reg[4:0] rd,
    output reg[31:0] result,
    output reg[31:0] mem_data,
    output reg MEM_WRITE_SEL
);

    always@(posedge clk) begin
        WE <= WE_in;
        rd <= rd_in;
        result <= result_in;
        mem_data <= mem_data_in;
        MEM_WRITE_SEL <= MEM_WRITE_SEL_in;
    end

endmodule