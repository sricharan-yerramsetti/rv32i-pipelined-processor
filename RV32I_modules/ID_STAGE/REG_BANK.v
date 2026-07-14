module REG_BANK(
    input[4:0] rs1,
    input[4:0] rs2,
    input[4:0] rd,
    input[31:0] rd_data,
    input WE,
    input clk,
    output reg[31:0] rs1_data,
    output reg[31:0] rs2_data
);
reg signed[31:0] x[0:31]; // signed registers



initial begin
    $readmemh("REG_BANK.hex", x);
end

always@(*) begin
    rs1_data = x[rs1];
    rs2_data = x[rs2];
end
always@(negedge clk) begin
    if((WE == 1'b1)&&(rd != 0)) begin
        x[rd] <= rd_data;         // writing to register bank at the negitve edge of clk
    end

end
endmodule