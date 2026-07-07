module EX_MEM(
    input clk,
    input[4:0] rd_in,
    input[31:0] result_in,
    input MEM_WRITE_in,
    input WE_in,
    input[31:0] rs2_data_in,
    input MEM_READ_in,
    input MEM_WRITE_SEL_in,
    output reg [4:0] rd,
    output reg [31:0] result,
    output reg MEM_WRITE,
    output reg WE,
    output reg [31:0] rs2_data,
    output reg MEM_READ,
    output reg MEM_WRITE_SEL
    );

always@(posedge clk) begin
    rd <= rd_in;
    result <= result_in;
    MEM_WRITE <= MEM_WRITE_in;
    WE <= WE_in;
    rs2_data <= rs2_data_in;
    MEM_READ <= MEM_READ_in;
    MEM_WRITE_SEL <= MEM_WRITE_SEL_in;
end

endmodule