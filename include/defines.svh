`ifndef DEFINES_SVH
`define DEFINES_SVH

`define RAM_CAPACITY_B 128
`define ADDR_SIZE      $clog2(`RAM_CAPACITY_B)
`define WORD_SIZE_B    4
`define WORD_SIZE      8*`WORD_SIZE_B

`define INSTR_OPCODE     instr[6:0]
`define INSTR_RD         instr[11:7]
`define INSTR_FUNCT3     instr[14:12]
`define INSTR_RS1        instr[19:15]
`define INSTR_RS2        instr[24:20]
`define INSTR_FUNCT7     instr[31:25]
`define INSTR_I_TYPE_IMM instr[31:20]
`define INSTR_S_TYPE_IMM {instr[31:25], instr[11:7]} 
`define INSTR_J_TYPE_IMM instr[31:12]

`endif