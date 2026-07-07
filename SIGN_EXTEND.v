module SIGN_EXTEND(
    input[24:0] inst_part,
    input[3:0] TYPE,
    input UNSIGNED,
    output reg [31:0] imm
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


always@(*) begin
    case(TYPE)
        r_type : begin
                    imm = 32'd0;
                 end

        i_type : begin
                    if(UNSIGNED == 1'b1) begin
                        imm = {20'd0,inst_part[24:13]};
                    end
                    else begin
                        imm = (inst_part[24] == 1'b1) ? {20'b1111_1111_1111_1111_1111,inst_part[24:13]}:{20'd0,inst_part[24:13]};
                    end
                 end

        lw_type : begin
                    imm = (inst_part[24] == 1'b1) ? {20'b1111_1111_1111_1111_1111,inst_part[24:13]}:{20'd0,inst_part[24:13]};
                  end

        s_type : begin
                    imm = (inst_part[24] == 1'b1) ? {20'b1111_1111_1111_1111_1111,inst_part[24:18],inst_part[4:0]}:{20'd0,inst_part[24:18],inst_part[4:0]};
                 end

        b_type : begin
                    imm = (inst_part[24] == 1'b1) ?{19'b1111111111111111111,inst_part[24],inst_part[0],inst_part[23:18],inst_part[4:1],1'b0}:{19'd0,inst_part[24],inst_part[0],inst_part[23:18],inst_part[4:1],1'b0};
                 end 

        lui_type : begin
                        imm = {inst_part[24:5],12'd0};
                   end

        auipc_type : begin
                        imm = {inst_part[24:5],12'd0};
                     end
                
        j_type : begin
                        imm = (inst_part[24] == 1'b1) ? {11'b11111111111,inst_part[24],inst_part[12:5],inst_part[13],inst_part[23:14],1'b0}:{11'd0,inst_part[24],inst_part[12:5],inst_part[13],inst_part[23:14],1'b0};
                 end

        jalr_type : begin
                            imm = (inst_part[24] == 1'b1) ? {20'b1111_1111_1111_1111_1111,inst_part[24:13]}:{20'd0,inst_part[24:13]};
                      end
    endcase
end






endmodule