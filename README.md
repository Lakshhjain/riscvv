# RISC-V Single-Cycle Processor — RV32I Subset in Verilog HDL

![Verilog](https://img.shields.io/badge/HDL-Verilog-blue)
![ISA](https://img.shields.io/badge/ISA-RISC--V%20RV32I-green)
![Simulator](https://img.shields.io/badge/Simulator-Icarus%20Verilog-orange)
![Waveform](https://img.shields.io/badge/Waveform-GTKWave-purple)
![Status](https://img.shields.io/badge/Status-Verified-brightgreen)

A fully functional 32-bit single-cycle RISC-V processor implementing a subset of the RV32I base integer ISA, designed in Verilog HDL and verified using Icarus Verilog and GTKWave.

Built as a mini-project for the CMOS VLSI Design course at **Dayananda Sagar College of Engineering (DSCE), VTU, Bangalore**.

---

## Team

| Name | USN |
|------|-----|
| Abhinav Kumbar | 1DS24ET006 |
| Deepanshu Das | 1DS24ET030 |
| Haripriya Hegde | 1DS24ET039 |
| Laksh Ambani | 1DS24ET054 |

---

## Supported Instructions

| Format | Opcode | Instructions | Operation |
|--------|--------|-------------|-----------|
| R-type | 0110011 | ADD, SUB, AND, OR, SLL, SRL, SRA | Register-register ALU |
| I-type | 0000011 | LW | Load word from memory |
| I-type | 0010011 | ADDI | Register-immediate add |
| I-type | 1100111 | JALR | Jump to rs1+imm, save PC+4 |
| S-type | 0100011 | SW | Store word to memory |
| B-type | 1100011 | BEQ | Branch if rs1 == rs2 |
| J-type | 1101111 | JAL | Jump to PC+imm, save PC+4 |

---

## Architecture

The processor follows the classic single-cycle RISC-V datapath:

```
IF → ID → EX → MEM → WB
(all in one clock cycle)
```

### Module List

| Module | Description |
|--------|-------------|
| `program_counter` | Stores current PC, resets to 0 |
| `pc_plus4` | Computes PC + 4 |
| `instruction_memory` | 64-word ROM, word-addressed via addr[7:2] |
| `registerfile` | 32 × 32-bit registers, x1=10, x2=5 on reset |
| `immgen` | Sign-extends immediates for I/S/B/J types |
| `controlunit` | Decodes opcode, generates all control signals |
| `alucontrol` | Maps {aluop, funct7, funct3} to 4-bit ALU opcode |
| `alu_unit` | AND, OR, ADD, SUB, SLL, SRL, SRA + zero flag |
| `datamemory` | 64-word RAM, word-addressed, synchronous write |
| `adder` | Generic 32-bit adder for branch/jump target |
| `andlogic` | branch AND zero → branch-taken signal |
| `top_module` | Structural top-level connecting all modules |

### PC-Next Priority Logic

```verilog
assign pc_next = jalr    ? jalr_target   :
                 jal     ? branch_target :
                 and_out ? branch_target :
                           pc_plus4_out;
```

---

## How to Run

### Requirements
- [Icarus Verilog](https://steveicarus.github.io/iverilog/) — `iverilog` + `vvp`
- [GTKWave](https://gtkwave.sourceforge.net/) — waveform viewer

### Steps

```bash
# 1. Clone the repo
git clone https://github.com/yourusername/riscv-single-cycle.git
cd riscv-single-cycle

# 2. Compile
iverilog -o processor.out top_module.v tb_top.v

# 3. Run simulation (generates wave.vcd)
vvp processor.out

# 4. View waveforms
gtkwave wave.vcd
```

---

## Testbench

The testbench (`tb_top.v`) runs for **400ns (40 clock cycles)** covering all 29 pre-loaded test instructions:

```
x1=10, x2=5 on reset

Cycles 1–7   : R-type  (ADD, SUB, AND, OR, SLL, SRL, SRA)
Cycles 8–10  : ADDI    (positive, negative, zero result)
Cycles 11–13 : SW      (store to data memory)
Cycles 14–16 : LW      (reload from data memory)
Cycles 17–25 : BEQ     (taken × 2, not-taken × 1)
Cycle  26    : JAL     (jump + link)
Cycle  29    : JALR    (jump to register + link)
```

### Expected Results

| Register | Value | Instruction |
|----------|-------|-------------|
| x3 | 15 | ADD x1+x2 |
| x4 | 5 | SUB x1-x2 |
| x5 | 0 | AND x1&x2 |
| x6 | 15 | OR x1\|x2 |
| x7 | 320 | SLL x1<<x2 |
| x8 | 10 | SRL x7>>x2 |
| x9 | 10 | SRA x7>>>x2 |
| x10 | 30 | ADDI x1+20 |
| x11 | 0xFFFFFFFF | ADDI x0+(-1) |

---

## Key Design Notes

- **Word addressing** — both memories use `addr[7:2]`, discarding lower 2 bits
- **Shift amount** — uses `B[4:0]` per RV32I spec (max 31 positions)
- **SRA** — implemented as `$signed(A) >>> B[4:0]` for arithmetic right shift
- **Branch offset** — immgen encodes bit 0 = 0, no extra shift needed
- **JALR target** — bit 0 cleared: `{alu_result[31:1], 1'b0}` per spec
- **Control defaults** — set at top of always block to prevent latch inference

---

## Not Yet Supported

- `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`
- `LUI`, `AUIPC`
- `XOR`, `SLT`, `SLTU`
- `XORI`, `ORI`, `ANDI`, `SLTI`
- `JAL`/`JALR` are supported; full pipeline is not

---

## References

1. Patterson & Hennessy — *Computer Organization and Design RISC-V Edition*, Morgan Kaufmann
2. RISC-V International — [The RISC-V ISA Manual](https://riscv.org/specifications/)
3. [Icarus Verilog Documentation](https://steveicarus.github.io/iverilog/)
4. [GTKWave Documentation](https://gtkwave.sourceforge.net/)

---

## License

MIT License — free to use for academic and personal projects.
