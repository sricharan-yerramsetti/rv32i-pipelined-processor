module IF_ID(
    input clk,
    input FREEZE,
    input NOP_IF_ID,
    input[31:0] pc_in,
    input[31:0] inst_in,
    output reg[31:0] pc,
    output reg[31:0] inst
);



always@(posedge clk) begin

    if((NOP_IF_ID == 1'b1)) begin
        pc <= pc_in;
        inst <= {12'd0,5'd0,3'd0,5'd0,7'b0010011};
    end

    else if((FREEZE == 1'b1)) begin
        pc <= pc;
        inst <= inst;
    end

    else begin
        pc <= pc_in;
        inst <= inst_in;
    end
    
end









endmodule