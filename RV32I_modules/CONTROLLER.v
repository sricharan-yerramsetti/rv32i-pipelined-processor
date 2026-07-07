module CONTROLLER(
    input clk,
    input[31:0] inst,
    input HAZARD,
    input signed[31:0] result,
    output reg[3:0] TYPE,
    output reg MEM_READ,
    output reg[1:0] PC_SRC,
    output reg UNSIGNED,
    output reg NOP_IF_ID,
    output reg[1:0] OP_1,
    output reg[1:0] OP_2,
    output reg MEM_WRITE,
    output reg WE,
    output reg NOP_ID_EX,
    output reg FREEZE,
    output reg[3:0] ALU_OP,
    output reg MEM_WRITE_SEL
    
);
localparam r_type = 4'b0000 ;
localparam i_type = 4'b0001 ;
localparam lw_type = 4'b0010;
localparam s_type = 4'b0011 ;
localparam b_type = 4'b0100 ;
localparam lui_type = 4'b0101;
localparam auipc_type = 4'b0110;
localparam j_type = 4'b0111;
localparam jalr_type = 4'b1000;

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

localparam r_opcode = 7'b0110011;
localparam i_opcode = 7'b0010011;
localparam lw_opcode = 7'b0000011;
localparam s_opcode = 7'b0100011;
localparam b_opcode = 7'b1100011;
localparam lui_opcode = 7'b0110111;
localparam auipc_opcode = 7'b0010111;
localparam j_opcode = 7'b1101111;
localparam jalr_opcode = 7'b1100111;

localparam flow = 2'b00;
localparam stall = 2'b01;
localparam jump = 2'b10;

reg[1:0] state = 2'b00 ;
reg[1:0] next_state = 2'b00;

wire[6:0] op_code;




assign op_code = inst[6:0];

always@(*) begin
    if((HAZARD == 1'b0)&&(state == flow)) begin
        case(op_code)
            r_opcode : begin
                            TYPE = r_type;
                            MEM_READ = 1'b0;
                            PC_SRC = 2'b01;
                            UNSIGNED = 1'b0;
                            NOP_IF_ID = 1'b0;
                            OP_1 = 2'b00;
                            OP_2 = 2'b00;
                            MEM_WRITE = 1'b0;
                            WE = 1'b1;
                            NOP_ID_EX = 1'b0;
                            FREEZE = 1'b0;
                            case({inst[31:25],inst[14:12]})
                                {7'b000_0000,3'b000} : ALU_OP = ADD;
                                {7'b010_0000,3'b000} : ALU_OP = SUB;
                                {7'b000_0000,3'b100} : ALU_OP = XOR;
                                {7'b000_0000,3'b110} : ALU_OP = OR;
                                {7'b000_0000,3'b111} : ALU_OP = AND;
                                {7'b000_0000,3'b001} : ALU_OP = SLL;
                                {7'b000_0000,3'b101} : ALU_OP = SRL;
                                {7'b010_0000,3'b101} : ALU_OP = SRA;
                                {7'b000_0000,3'b010} : ALU_OP = LT;
                                {7'b000_0000,3'b011} : ALU_OP = LTU;
                                default : ALU_OP = ADD;
                            endcase
                            MEM_WRITE_SEL = 1'b0;
                         end

            i_opcode : begin
                            TYPE = i_type;
                            MEM_READ = 1'b0;
                            PC_SRC = 2'b01;
                            case(inst[14:12])
                                3'b001 : UNSIGNED = 1'b1;
                                3'b101 : UNSIGNED = 1'b1;
                                default : UNSIGNED = 1'b0;
                            endcase
                            NOP_IF_ID = 1'b0;
                            OP_1 = 2'b00;
                            OP_2 = 2'b10;
                            MEM_WRITE = 1'b0;
                            WE = 1'b1;
                            NOP_ID_EX = 1'b0;
                            FREEZE = 1'b0;
                            case(inst[14:12])
                                {3'b000} : ALU_OP = ADD;
                                {3'b100} : ALU_OP = XOR;
                                {3'b110} : ALU_OP = OR;
                                {3'b111} : ALU_OP = AND;
                                {3'b001} : ALU_OP = SLL;
                                {3'b101} : ALU_OP = inst[30] ? SRA : SRL;
                                {3'b010} : ALU_OP = LT;
                                {3'b011} : ALU_OP = LTU;
                                default : ALU_OP = ADD;
                            endcase
                            MEM_WRITE_SEL = 1'b0;
                            
                       end
            
            lw_opcode : begin
                            TYPE = lw_type;
                            MEM_READ = 1'b1;
                            PC_SRC = 2'b01;
                            UNSIGNED = 1'b0;
                            NOP_IF_ID = 1'b0;
                            OP_1 = 2'b00;
                            OP_2 = 2'b10;
                            MEM_WRITE = 1'b0;
                            WE = 1'b1;
                            NOP_ID_EX = 1'b0;
                            FREEZE = 1'b0;
                            ALU_OP = ADD;
                            MEM_WRITE_SEL = 1'b1;
                            
                        end

            s_opcode : begin
                            TYPE = s_type;
                            MEM_READ = 1'b0;
                            PC_SRC = 2'b01;
                            UNSIGNED = 1'b0;
                            NOP_IF_ID  = 1'b0;
                            OP_1 = 2'b00;
                            OP_2 = 2'b10;
                            MEM_WRITE = 1'b1;
                            WE = 1'b0;
                            NOP_ID_EX = 1'b0;
                            FREEZE = 1'b0;
                            ALU_OP = ADD;
                            MEM_WRITE_SEL = 1'b0;
                            
                       end
                
            b_opcode : begin
                            TYPE = b_type;
                            MEM_READ = 1'b0;
                            PC_SRC = 2'b00;
                            UNSIGNED = 1'b0;
                            NOP_IF_ID = 1'b0;
                            OP_1 = 2'b00;
                            OP_2 = 2'b00;
                            MEM_WRITE = 1'b0;
                            WE = 1'b0;
                            NOP_ID_EX = 1'b0;
                            FREEZE = 1'b1;
                            case(inst[14:12])
                                3'b000 : ALU_OP = EQ;
                                3'b001 : ALU_OP = NE;
                                3'b100 : ALU_OP = LT;
                                3'b101 : ALU_OP = GE;
                                3'b110 : ALU_OP = LTU;
                                3'b111 : ALU_OP = GEU;
                                default : ALU_OP = EQ;
                            endcase
                            MEM_WRITE_SEL = 1'b0;

                       end
                
            lui_opcode : begin
                            TYPE = lui_type;
                            MEM_READ = 1'b0;
                            PC_SRC = 2'b01;
                            UNSIGNED = 1'b0;
                            NOP_IF_ID = 1'b0;
                            OP_1 = 2'b10;
                            OP_2 = 2'b10;
                            MEM_WRITE = 1'b0;
                            WE = 1'b1;
                            NOP_ID_EX = 1'b0;
                            FREEZE = 1'b0;
                            ALU_OP = ADD;
                            MEM_WRITE_SEL = 1'b0;
                         end

            auipc_opcode : begin
                                TYPE = auipc_type;
                                MEM_READ = 1'b0;
                                PC_SRC = 2'b01;
                                UNSIGNED = 1'b0;
                                NOP_IF_ID = 1'b0;
                                OP_1 = 2'b01;
                                OP_2 = 2'b10;
                                MEM_WRITE = 1'b0;
                                WE = 1'b1;
                                NOP_ID_EX = 1'b0;
                                FREEZE = 1'b0;
                                ALU_OP = ADD;
                                MEM_WRITE_SEL = 1'b0;

                           end

            j_opcode : begin
                            TYPE = j_type;
                            MEM_READ = 1'b0;
                            PC_SRC = 2'b10;
                            UNSIGNED = 1'b0;
                            NOP_IF_ID = 1'b1;
                            OP_1 = 2'b01;
                            OP_2 = 2'b01;
                            MEM_WRITE = 1'b0;
                            WE = 1'b1;
                            NOP_ID_EX = 1'b0;
                            FREEZE = 1'b0;
                            ALU_OP = ADD;
                            MEM_WRITE_SEL = 1'b0;

                       end

            jalr_opcode : begin
                                TYPE = jalr_type;
                                MEM_READ = 1'b0;
                                PC_SRC = 2'b01;
                                UNSIGNED = 1'b0;
                                NOP_IF_ID = 1'b1;
                                OP_1 = 2'b01;
                                OP_2 = 2'b01;
                                MEM_WRITE = 1'b0;
                                WE = 1'b1;
                                NOP_ID_EX = 1'b0;
                                FREEZE = 1'b0;
                                ALU_OP = ADD;
                                MEM_WRITE_SEL = 1'b0;

                          end


            
        endcase
    end

    else if((HAZARD == 1'b1)&&(state == flow)) begin
        NOP_ID_EX = 1'b1;
        PC_SRC = 2'b00;
        FREEZE = 1'b1;
        NOP_IF_ID = 1'b0;
        TYPE = 4'b0000;
        MEM_READ = 1'b0;
        MEM_WRITE = 1'b0;
        WE = 1'b0;     
        UNSIGNED = 1'b0;
        OP_1 = 2'b00;
        OP_2 = 2'b00;
        ALU_OP = 4'b0000;
        MEM_WRITE_SEL = 1'b0;
    end


    else if(state == stall) begin
        if(result == 1) begin
            TYPE = b_type;
            MEM_READ = 1'b0;
            PC_SRC = 2'b10;
            UNSIGNED = 1'b0;
            NOP_IF_ID = 1'b1;
            OP_1 = 2'b00;
            OP_2 = 2'b10;
            MEM_WRITE = 1'b0;
            WE = 1'b0;
            NOP_ID_EX = 1'b1;
            FREEZE = 1'b0;
            ALU_OP = ADD;
            MEM_WRITE_SEL = 1'b0;
        end

        else begin
            TYPE = b_type;
            MEM_READ = 1'b0;
            PC_SRC = 2'b01;
            UNSIGNED = 1'b0;
            NOP_IF_ID = 1'b0;
            OP_1 = 2'b00;
            OP_2 = 2'b10;
            MEM_WRITE = 1'b0;
            WE = 1'b0;
            NOP_ID_EX = 1'b1;
            FREEZE = 1'b0;
            ALU_OP = ADD;
            MEM_WRITE_SEL = 1'b0;
        end
    end

    else if(state == jump) begin
        TYPE = i_type;
        MEM_READ = 1'b0;
        PC_SRC = 2'b11;
        UNSIGNED = 1'b0;
        NOP_IF_ID = 1'b1;
        OP_1 = 2'b00;
        OP_2 = 2'b10;
        MEM_WRITE = 1'b0;
        WE = 1'b1;
        NOP_ID_EX = 1'b1;
        FREEZE = 1'b0;
        ALU_OP = ADD;
        MEM_WRITE_SEL = 1'b0;
    end
end

always@(posedge clk) begin
    state <= next_state;
end

always@(*) begin
    case(state)
        flow : begin
                case(op_code)
                    b_opcode : next_state = (HAZARD) ? flow : stall;
                    jalr_opcode : next_state = (HAZARD) ? flow : jump;
                    default : next_state = flow;
                endcase
               end
        stall : begin
                    next_state = flow;
                end
        jump : begin
                    next_state = flow; 
               end
    endcase
end

endmodule