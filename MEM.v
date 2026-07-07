module MEM(
    input clk,
    input MEM_READ,
    input[31:0] rs2_data,
    input[31:0] addr,
    input MEM_WRITE,
    output[31:0] mem_data
);


reg[7:0] mem[0:4095];
integer i;

initial begin
    for(i=0; i<4096; i=i+1) mem[i] = 8'h00;
    $readmemh("MEM.hex",mem);
end

assign mem_data = (MEM_READ == 1'b1)?{mem[addr+3],mem[addr+2],mem[addr+1],mem[addr]}:0;

always@(negedge clk) begin
    if(MEM_WRITE == 1'b1) begin
        {mem[addr+3],mem[addr+2],mem[addr+1],mem[addr]} <= rs2_data;
    end

    else begin
        {mem[addr+3],mem[addr+2],mem[addr+1],mem[addr]} <= {mem[addr+3],mem[addr+2],mem[addr+1],mem[addr]};
    end
end









endmodule