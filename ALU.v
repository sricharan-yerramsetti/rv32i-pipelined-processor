module ALU(
    input[31:0] rs1_data,
    input[31:0] pc,
    input[31:0] rs2_data,
    input[31:0] imm,
    input[1:0] OP_1,
    input[1:0] OP_2,
    input[31:0] foredata_A,
    input[31:0] foredata_B,
    input FORWARD_A,
    input FORWARD_B,
    input[3:0] ALU_OP,
    output reg[31:0] result,
    output[31:0] jump_addr
);
localparam ADD = 4'b0000;
localparam SUB = 4'b0001;
localparam XOR = 4'b0010;
localparam OR = 4'b0011;
localparam AND = 4'b0100;
localparam SLL = 4'b0101;
localparam SRL = 4'b0110;
localparam SRA = 4'b0111;
localparam EQ = 4'b1000;
localparam NE = 4'b1001;
localparam LT = 4'b1010;
localparam GE = 4'b1011;
localparam LTU = 4'b1100;
localparam GEU = 4'b1101;


reg[31:0] operand1,operand2;

always@(*) begin


    if(FORWARD_A == 1'b1) begin
        operand1 = foredata_A;
    end

    else begin
        case(OP_1)
            2'b00 : operand1 = rs1_data;
            2'b01 : operand1 = pc;
            2'b10 : operand1 = 32'd0;
            default : operand1 = rs1_data;
        endcase
    end


    if(FORWARD_B == 1'b1) begin
        operand2 = foredata_B;
    end

    else begin
        case(OP_2)
            2'b00 : operand2 = rs2_data;
            2'b01 : operand2 = 32'd4;
            2'b10 : operand2 = imm;
            default : operand2 = rs2_data;
        endcase
    end

end

always @(*) begin
    case (ALU_OP) 
        ADD     : result = operand1 + operand2;
        SUB     : result = operand1 - operand2;
        XOR     : result = operand1 ^ operand2;
        OR      : result = operand1 | operand2;
        AND     : result = operand1 & operand2;
        SLL     : result = operand1 << operand2[4:0];
        SRL     : result = operand1 >> operand2[4:0];
        SRA     : result = $signed(operand1) >>> operand2[4:0];
        EQ      : result = (operand1 == operand2) ? 32'd1 : 32'd0;
        NE      : result = (operand1 != operand2) ? 32'd1 : 32'd0;
        LT      : result = ($signed(operand1) < $signed(operand2)) ? 32'd1 : 32'd0;
        GE      : result = ($signed(operand1) >= $signed(operand2)) ? 32'd1 : 32'd0;
        LTU     : result = (operand1 < operand2) ? 32'd1 : 32'd0;
        GEU     : result = (operand1 >= operand2) ? 32'd1 : 32'd0;        
        default : result = operand1 + operand2;
    endcase
end
assign jump_addr = (FORWARD_A == 1'b1)?foredata_A + $signed(imm):rs1_data + $signed(imm);
endmodule