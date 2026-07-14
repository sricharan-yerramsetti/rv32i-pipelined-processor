`timescale 1ns/1ps

module tb_top;

// ── clock ────────────────────────────────────────────────────────────────
reg clk = 0;
always #5 clk = ~clk;
// ── DUT ──────────────────────────────────────────────────────────────────
top_module DUT(.clk(clk));
// IF stage
wire[31:0] pc_if = DUT.IF_MODULE_INST.pc;
wire[31:0] inst_if = DUT.inst_if;
    
// ID stage
wire[31:0] pc_id = DUT.pc_id;
wire[31:0] inst_id = DUT.inst_id;
    
// EX stage
wire[31:0] pc_ex = DUT.pc_ex;
wire[3:0]  alu_op = DUT.ALU_OP_ex;
wire[31:0] result = DUT.result_alu;

// WB stage
wire we_wb = DUT.WE_wb;
wire[4:0] rd_wb = DUT.rd_wb;
wire[31:0] rd_data = DUT.rd_data_wb;

// Hazard / forwarding
wire hazard = DUT.HAZARD;
wire freeze = DUT.FREEZE;
wire[1:0] pc_src = DUT.PC_SRC;


initial begin
    $display("╔══════╦══════════╦══════════╦══════════╦══════╦═══════════╦══════════╗");
    $display("║ Time ║  PC_IF   ║ INST_ID  ║  RESULT  ║WE_WB║  RD_DATA  ║ RD / HAZ ║");
    $display("╠══════╬══════════╬══════════╬══════════╬══════╬═══════════╬══════════╣");
end

// ──  monitor ────────────────────────────────────────────────────
always @(posedge clk) begin
    #1;
    $display("║ %4t ║ %8h ║ %8h ║ %8h ║  %1b   ║ %9h ║ x%2d / %1b  ║",$time,pc_if,inst_id,result,we_wb,rd_data,rd_wb,hazard);
end

initial begin
    $dumpfile("rv32i_wave.vcd");
    $dumpvars(0, tb_top);
end

// ── run for enough cycles then stop ──────────────────────────────────────
initial begin
    #5000;
    $display("╚══════╩══════════╩══════════╩══════════╩══════╩═══════════╩══════════╝");
    $display("\n=== REGISTER FILE SNAPSHOT AT END ===");
    begin : reg_dump
        integer j;
        for (j = 0; j < 32; j = j + 1) begin
            if (DUT.REG_BANK_INST.x[j] !== 32'hxxxxxxxx)
                $display("  x%0d\t= %0d\t(0x%h)", j, $signed(DUT.REG_BANK_INST.x[j]), DUT.REG_BANK_INST.x[j]);
        end
    end
    $display("\n=== MEMORY SNAPSHOT [0x00–0x1F] ===");
    begin : mem_dump
        integer k;
        for (k = 0; k < 32; k = k + 4) begin
            $display("  MEM[%2h] = %h %h %h %h  →  word = %h",
                k,
                DUT.MEM_INST.mem[k],
                DUT.MEM_INST.mem[k+1],
                DUT.MEM_INST.mem[k+2],
                DUT.MEM_INST.mem[k+3],
                {DUT.MEM_INST.mem[k+3],
                 DUT.MEM_INST.mem[k+2],
                 DUT.MEM_INST.mem[k+1],
                 DUT.MEM_INST.mem[k]}
            );
        end
    end
    $finish;
end

endmodule
