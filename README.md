# rv32i-pipelined-processor
RV32I 5-stage pipelined processor implemented in Verilog with full forwarding, hazard detection, and RISC-V toolchain integration. Verified using Bellman-Ford algorithm execution on custom hardware.
# RV32I 5-Stage Pipelined Processor

**A complete Verilog implementation with Harvard architecture**

## Overview

This project implements a complete 5-stage pipelined RISC-V (RV32I) processor in Verilog. The design follows classic computer architecture principles with separate instruction and data memory (Harvard architecture), integrated hazard detection, data forwarding, and proper branch/jump handling. The processor successfully executes real C programs compiled with the RISC-V GNU toolchain, verified through simulation with complex algorithms like Bellman-Ford graph traversal.

## Key Features

| Feature | Details |
|---|---|
| **Architecture** | 5-stage pipeline (IF → ID → EX → MEM → WB) |
| **ISA Support** | RV32I base instruction set (30+ instructions) |
| **Memory Model** | Harvard architecture with separate IMEM & DMEM |
| **Hazard Handling** | Load-use detection + data forwarding (2 paths) |
| **Branch Logic** | Delayed branch slots + branch prediction |
| **Jump Support** | JAL, JALR with proper return address handling |
| **ALU Operations** | Arithmetic, logical, shift, comparison (14 operations) |
| **Simulation** | Verified with real C programs (no libc dependency) |

## Pipeline Architecture

The processor implements a classic 5-stage pipeline where each stage processes one instruction in parallel, significantly improving throughput over a single-cycle or multicycle design. This introduces data and control hazards that are carefully handled to maintain correctness.

### Pipeline Stages

**1. Instruction Fetch (IF)**
Retrieves the next instruction from instruction memory using the program counter (PC). The PC is updated based on branch/jump decisions from previous stages — sequential fetch follows `PC ← PC + 4`, while branches and jumps override this.

**2. Instruction Decode (ID)**
Decodes the fetched instruction to extract operation type, register operands, and immediate values. Reads register file values for `rs1` and `rs2`. The controller generates control signals based on the opcode and `funct3`/`funct7` fields, and this stage performs sign extension for I/S/B-type immediates.

**3. Execute (EX)**
Performs the actual computation — ALU operations, comparisons, or address calculations. Uses data forwarding to bypass earlier pipeline stages when an instruction depends on the result of the immediately preceding one. For branches, compares operands and signals jumps to the controller; for loads/stores, calculates the memory address.

**4. Memory Access (MEM)**
Handles all memory transactions: loads read from data memory, stores write to data memory. Passes through ALU results for non-memory instructions and manages byte-select logic for different load/store widths (`lw`, `lb`, `lbu`, etc.).

**5. Write Back (WB)**
Updates the destination register with the final result (from the ALU or memory). Does not write for store instructions or comparison operations — the write-enable (`WE`) signal controls whether the register file updates.

## Hazard Handling & Data Forwarding

Pipelined execution creates three main types of hazards: structural (not present here, no shared resources), data (RAW — Read After Write), and control (branches/jumps).

### Data Hazards (Load-Use)
When the current instruction depends on a load result still in the pipeline, forwarding isn't possible since the data isn't ready yet. The hazard detection unit stalls the pipeline for one cycle by freezing the IF/ID and ID/EX latches and injecting a NOP into the EX stage. After one stall, the loaded data becomes available in the EX stage and can be forwarded.

### Data Forwarding
For most data dependencies (non-load), results are forwarded directly from earlier stages. The forwarding unit checks whether the destination register of an EX or MEM stage instruction matches the source operands of the current ID stage instruction. If so, the result is bypassed directly into the ALU inputs, eliminating unnecessary stalls and allowing consecutive dependent instructions to execute with minimal delay.

### Control Hazards (Branches & Jumps)
Branch instructions (`beq`, `bne`, `blt`, etc.) make decisions about the next instruction address. In this design, branches stall the pipeline for one cycle (the branch slot) — the branch is evaluated in the EX stage, and if taken, the PC is updated. Jump instructions (`jal`, `jalr`) similarly cause a one-cycle stall. This delayed-branch approach is simpler than dynamic branch prediction but adds a known latency.

## Module Architecture

| Module | Role |
|---|---|
| **IF_MODULE** | Manages the PC and instruction memory (IMEM); selects the next PC (sequential, branch, jump, or stall) and outputs the current instruction and PC for ID. |
| **CONTROLLER** | Decodes opcode and generates control signals for the pipeline; recognizes 9 instruction types (R, I, Load, Store, Branch, LUI, AUIPC, JAL, JALR); manages hazard and branch/jump delay-slot state machine. |
| **REG_BANK** | 32×32-bit general-purpose register file (x0–x31) with dual read ports (rs1, rs2) and single write port (WB); x0 hardwired to zero. |
| **SIGN_EXTEND** | Extracts and sign-extends immediates for I/S/B (12-bit) and U/J (20-bit) instruction formats into a 32-bit signed value. |
| **ALU** | Performs ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, and comparisons (EQ, NE, LT, GE, LTU, GEU); selects operands via mux logic and integrates forwarding paths. |
| **HAZARD_DETECTION_UNIT** | Monitors ID/EX and IF/ID latches to detect load-use dependencies and triggers pipeline freeze + NOP injection. |
| **FORWARDING_UNIT** | Compares rs1/rs2 of the current EX instruction against rd of the MEM and WB stage instructions to select the correct forwarding path (register file, EX result, or MEM result). |
| **MEM** | Data memory supporting reads (loads) and writes (stores); initialized from a hex file for testing. |
| **IF_ID / ID_EX / EX_MEM / MEM_WB** | Pipeline latches between stages; updated on clock edges, can be frozen (`FREEZE`) or flushed (`NOP_*`) to preserve data consistency across stage boundaries. |

## Key Control Signals

| Signal | Description |
|---|---|
| `TYPE` | Instruction type (R, I, Load, Store, Branch, etc.) |
| `ALU_OP` | ALU operation code (ADD, SUB, XOR, AND, OR, SLL, SRL, SRA, comparisons, etc.) |
| `OP_1`, `OP_2` | ALU input select: `00`=register, `01`=PC, `10`=0 or immediate |
| `MEM_READ` | Enables data memory read (loads) |
| `MEM_WRITE` | Enables data memory write (stores) |
| `WE` | Register file write-enable |
| `PC_SRC` | PC select: `00`=hold, `01`=sequential (+4), `10`=branch offset, `11`=jump target |
| `FREEZE` | Stall signal; freezes IF/ID and ID/EX latches |
| `NOP_IF_ID`, `NOP_ID_EX` | NOP injection — converts instruction to `ADD x0, x0, x0` during stalls/delay slots |
| `UNSIGNED` | Distinguishes signed (LT, GE) vs. unsigned (LTU, GEU) comparisons |
| `MEM_WRITE_SEL` | Selects the data source written to memory (load vs. store path) |

## Supported Instruction Types

- **R-Type** — `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu`: register-register operations.
- **I-Type** — `addi`, `andi`, `ori`, `xori`, `slli`, `srli`, `srai`, `slti`, `sltiu`, `jalr`: register-immediate operations.
- **S-Type** — `sw`, `sh`, `sb`: store to memory at base register + offset.
- **Load-Type** — `lw`, `lh`, `lb`, `lhu`, `lbu`: load from memory into a destination register.
- **B-Type** — `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`: conditional branches.
- **U-Type** — `lui`, `auipc`: 20-bit immediate operations (load upper bits / add to PC).
- **J-Type** — `jal`: unconditional jump, storing the return address (PC + 4).

## File Structure

```
├── ALU.v                       # Arithmetic Logic Unit with forwarding mux logic
├── CONTROLLER.v                # Control unit — decodes opcodes, generates control signals
├── EX_MEM.v                    # Pipeline latch: EX → MEM
├── FORWARDING_UNIT.v           # Data forwarding path detection
├── HAZARD_DETECTION_UNIT.v     # Load-use hazard detection & stall triggering
├── ID_EX.v                     # Pipeline latch: ID → EX
├── IF_ID.v                     # Pipeline latch: IF → ID
├── IF_MODULE.v                 # Instruction fetch unit (PC + IMEM)
├── MEM.v                       # Data memory module
├── MEM_WB.v                    # Pipeline latch: MEM → WB
├── REG_BANK.v                  # Register file
├── SIGN_EXTEND.v                # Immediate sign extension
├── IM.hex, MEM.hex, REG_BANK.hex   # Memory initialization files
└── rv32i_wave.vcd, sim.vvp     # Simulation artifacts (waveform, executable)
```

## Testing & Verification

The processor is verified through simulation with **Icarus Verilog**. A custom toolchain compiles C programs (without libc) into RV32I machine code; the generated hex files are loaded into instruction memory and the simulation runs to completion, with waveforms available to trace instruction flow through the pipeline.

Test coverage includes:
- Basic arithmetic and logical operations (add, sub, and, or, xor, shifts)
- Register-immediate operations (addi, slti, etc.)
- Memory operations (load/store with different widths)
- Conditional branches (beq, bne, blt, etc.)
- Jumps (jal, jalr) with return address handling
- Complex algorithms (Bellman-Ford, etc.)
- Data forwarding scenarios (consecutive dependent instructions)
- Load-use stall scenarios (immediate dependency on load result)

## Design Decisions & Trade-offs

- **Delayed Branches** — Branch outcomes are resolved in the EX stage (2 cycles after fetch). Rather than flushing the pipeline, a one-cycle delay slot is used, simplifying control logic at the cost of latency.
- **No Branch Prediction** — Branches are assumed not-taken (fall-through), which is simple but can stall the pipeline when branches are frequently taken.
- **Harvard Architecture** — Separate instruction and data memory avoid structural hazards and simplify memory bandwidth analysis, at the cost of more silicon than a unified-memory design.
- **Full Data Forwarding** — Two forwarding paths (EX and MEM) eliminate most stalls; only load-use dependencies require a stall.
- **RV32I Base Set** — Only the base integer ISA is supported (no floating-point, atomic, or vector extensions), keeping the design tractable.
- **Fixed Latency Memory** — Reads and writes complete in one cycle, avoiding the complexity of variable-latency memory or cache coherency.

## Lessons Learned & Debugging

- **Pipeline Latch Timing** — Consistent use of non-blocking assignments (`<=`) is essential to avoid race conditions between stages.
- **NOP Injection Encoding** — NOPs are implemented as `ADD x0, x0, x0`; this must match the ISA exactly or the pipeline executes unintended instructions.
- **Hazard Detection Priority** — Load-use hazards require a stall, but forwarding from other stages can still proceed — the hazard unit must distinguish these cases carefully.
- **State Machine Correctness** — The controller's branch/jump delay-slot state machine required testing all transitions, especially with concurrent hazards.
- **Sign Extension Edge Cases** — Different immediate formats (12-bit, 20-bit) mean incorrect extraction/extension can silently produce wrong branch targets or operand values.
- **Memory Byte Ordering** — RISC-V uses little-endian byte order; byte loads (`lb`, `lbu`) require careful offset handling, caught via detailed memory-state inspection in the testbench.

## Performance Characteristics & Future Work

**Current performance:** The baseline design achieves roughly 1 instruction per cycle (IPC) on code with minimal data dependencies. Load-use hazards reduce this to ~0.8 IPC in typical programs, with additional latency from not-taken branch mispredictions.

**Potential enhancements:**
- Branch prediction with a simple 1-bit or 2-bit predictor
- Deeper pipeline (7–9 stages) for higher frequency
- L1 instruction/data cache hierarchy for realistic memory latency
- Floating-point extension (F) for scientific code

## References

- *Computer Organization and Design* — Hennessy & Patterson
- RISC-V Instruction Set Manual (Volume I: Base ISA)
- *Digital Design* — M. Morris Mano & Michael D. Ciletti
- RISC-V GNU Toolchain Documentation

---
*For detailed implementation notes, refer to the comments in the individual Verilog source files.*
