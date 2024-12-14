R_TYPE_OPCODE = '0110011'
I_TYPE_OPCODE = '0010011'
L_TYPE_OPCODE = '0000011'
S_TYPE_OPCODE = '0100011'
J_TYPE_OPCODE = '1101111'

def binstr_to_hexstr(binstr):
    decint = int(binstr, base=2)
    hexstr = str(format(decint, '08x'))
    return hexstr

def code_arg(arg, size):
    val = str(format(arg, '0'+size+'b'))
    return val

def code_add_instr(rd, rs1, rs2):
    assembly = 'add ' + 'x' + str(rd) + ', x' + str(rs1) + ', x' + str(rs2)
    rd = code_arg(rd, '5')
    rs1 = code_arg(rs1, '5')
    rs2 = code_arg(rs2, '5')
    instr_bin = '0000000' + rs2 + rs1 + '000' + rd + R_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_sub_instr(rd, rs1, rs2):
    assembly = 'sub ' + 'x' + str(rd) + ', x' + str(rs1) + ', x' + str(rs2)
    rd = code_arg(rd, '5')
    rs1 = code_arg(rs1, '5')
    rs2 = code_arg(rs2, '5')
    instr_bin = '0100000' + rs2 + rs1 + '000' + rd + R_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_mul_instr(rd, rs1, rs2):
    assembly = 'mul ' + 'x' + str(rd) + ', x' + str(rs1) + ', x' + str(rs2)
    rd = code_arg(rd, '5')
    rs1 = code_arg(rs1, '5')
    rs2 = code_arg(rs2, '5')
    instr_bin = '0000001' + rs2 + rs1 + '000' + rd + R_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_div_instr(rd, rs1, rs2):
    assembly = 'div ' + 'x' + str(rd) + ', x' + str(rs1) + ', x' + str(rs2)
    rd = code_arg(rd, '5')
    rs1 = code_arg(rs1, '5')
    rs2 = code_arg(rs2, '5')
    instr_bin = '0000001' + rs2 + rs1 + '100' + rd + R_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_rem_instr(rd, rs1, rs2):
    assembly = 'rem ' + 'x' + str(rd) + ', x' + str(rs1) + ', x' + str(rs2)
    rd = code_arg(rd, '5')
    rs1 = code_arg(rs1, '5')
    rs2 = code_arg(rs2, '5')
    instr_bin = '0000001' + rs2 + rs1 + '110' + rd + R_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_and_instr(rd, rs1, rs2):
    assembly = 'and ' + 'x' + str(rd) + ', x' + str(rs1) + ', x' + str(rs2)
    rd = code_arg(rd, '5')
    rs1 = code_arg(rs1, '5')
    rs2 = code_arg(rs2, '5')
    instr_bin = '0000000' + rs2 + rs1 + '111' + rd + R_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_or_instr(rd, rs1, rs2):
    assembly = 'or ' + 'x' + str(rd) + ', x' + str(rs1) + ', x' + str(rs2)
    rd = code_arg(rd, '5')
    rs1 = code_arg(rs1, '5')
    rs2 = code_arg(rs2, '5')
    instr_bin = '0000000' + rs2 + rs1 + '110' + rd + R_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_xor_instr(rd, rs1, rs2):
    assembly = 'xor ' + 'x' + str(rd) + ', x' + str(rs1) + ', x' + str(rs2)
    rd = code_arg(rd, '5')
    rs1 = code_arg(rs1, '5')
    rs2 = code_arg(rs2, '5')
    instr_bin = '0000000' + rs2 + rs1 + '100' + rd + R_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_sll_instr(rd, rs1, rs2):
    assembly = 'sll ' + 'x' + str(rd) + ', x' + str(rs1) + ', x' + str(rs2)
    rd = code_arg(rd, '5')
    rs1 = code_arg(rs1, '5')
    rs2 = code_arg(rs2, '5')
    instr_bin = '0000000' + rs2 + rs1 + '001' + rd + R_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_srl_instr(rd, rs1, rs2):
    assembly = 'srl ' + 'x' + str(rd) + ', x' + str(rs1) + ', x' + str(rs2)
    rd = code_arg(rd, '5')
    rs1 = code_arg(rs1, '5')
    rs2 = code_arg(rs2, '5')
    instr_bin = '0000000' + rs2 + rs1 + '101' + rd + R_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_slt_instr(rd, rs1, rs2):
    assembly = 'slt ' + 'x' + str(rd) + ', x' + str(rs1) + ', x' + str(rs2)
    rd = code_arg(rd, '5')
    rs1 = code_arg(rs1, '5')
    rs2 = code_arg(rs2, '5')
    instr_bin = '0000000' + rs2 + rs1 + '010' + rd + R_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_addi_instr(rd, rs1, imm):
    assembly = 'addi ' + 'x' + str(rd) + ', x' + str(rs1) + ', ' + str(imm)
    rd = code_arg(rd, '5')
    rs1 = code_arg(rs1, '5')
    imm = code_arg(imm, '12')
    instr_bin = imm + rs1 + '000' + rd + I_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_andi_instr(rd, rs1, imm):
    assembly = 'andi ' + 'x' + str(rd) + ', x' + str(rs1) + ', ' + str(imm)
    rd = code_arg(rd, '5')
    rs1 = code_arg(rs1, '5')
    imm = code_arg(imm, '12')
    instr_bin = imm + rs1 + '111' + rd + I_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_ori_instr(rd, rs1, imm):
    assembly = 'ori ' + 'x' + str(rd) + ', x' + str(rs1) + ', ' + str(imm)
    rd = code_arg(rd, '5')
    rs1 = code_arg(rs1, '5')
    imm = code_arg(imm, '12')
    instr_bin = imm + rs1 + '110' + rd + I_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_xori_instr(rd, rs1, imm):
    assembly = 'xori ' + 'x' + str(rd) + ', x' + str(rs1) + ', ' + str(imm)
    rd = code_arg(rd, '5')
    rs1 = code_arg(rs1, '5')
    imm = code_arg(imm, '12')
    instr_bin = imm + rs1 + '100' + rd + I_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_slli_instr(rd, rs1, imm):
    assembly = 'slli ' + 'x' + str(rd) + ', x' + str(rs1) + ', ' + str(imm)
    rd = code_arg(rd, '5')
    rs1 = code_arg(rs1, '5')
    imm = code_arg(imm, '12')
    instr_bin = imm + rs1 + '001' + rd + I_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_srli_instr(rd, rs1, imm):
    assembly = 'srli ' + 'x' + str(rd) + ', x' + str(rs1) + ', ' + str(imm)
    rd = code_arg(rd, '5')
    rs1 = code_arg(rs1, '5')
    imm = code_arg(imm, '12')
    instr_bin = imm + rs1 + '101' + rd + I_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_lw_instr(rd, rs1, imm):
    assembly = 'lw ' + 'x' + str(rd) + ', ' + hex(imm) + '(' + 'x'+str(rs1)+')'
    rd = code_arg(rd, '5')
    rs1 = code_arg(rs1, '5')
    imm = code_arg(imm, '12')
    instr_bin = imm + rs1 + '010' + rd + L_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_sw_instr(rs1, rs2, imm):
    assembly = 'sw ' + 'x' + str(rs2) + ', ' + hex(imm) + '(' + 'x'+str(rs1)+')'
    rs1 = code_arg(rs1, '5')
    # print(rs1)
    rs2 = code_arg(rs2, '5')
    # print(rs2)
    imm = code_arg(imm, '12')
    # print(imm)
    instr_bin = imm[0:7] + rs2 + rs1 + '010' + imm[7:12] + S_TYPE_OPCODE
    # print(instr_bin)
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

def code_jal_instr(rd, imm):
    assembly = 'jal ' + 'x' + str(rd) + ', ' + hex(imm)
    rd = code_arg(rd, '5')
    imm = code_arg(imm, '20')
    instr_bin = imm + rd + J_TYPE_OPCODE
    raw = binstr_to_hexstr(instr_bin)
    print(assembly+' => '+raw)

code_lw_instr(1, 0, 0xFC)
code_lw_instr(2, 0, 0xF8)
code_add_instr(3, 1, 2)
code_sub_instr(4, 1, 2)
code_mul_instr(5, 1, 2)
code_div_instr(6, 1, 2)
code_rem_instr(7, 1, 2)
code_and_instr(8, 1, 2)
code_or_instr(9, 1, 2)
code_xor_instr(10, 1, 2)
code_sll_instr(11, 1, 2)
code_srl_instr(12, 1, 2)
code_slt_instr(13, 1, 2)
code_addi_instr(14, 1, 73)
code_andi_instr(15, 1, 4095)
code_ori_instr(16, 1, 0)
code_xori_instr(17, 1, 0)
code_slli_instr(18, 1, 3)
code_srli_instr(19, 1, 3)
code_sw_instr(0, 3, 0xF4)
code_sw_instr(0, 4, 0xF0)
code_sw_instr(0, 5, 0xEC)
code_sw_instr(0, 6, 0xE8)
code_sw_instr(0, 7, 0xE4)
code_sw_instr(0, 8, 0xE0)
code_sw_instr(0, 9, 0xDC)
code_sw_instr(0, 10, 0xD8)
code_sw_instr(0, 11, 0xD4)
code_sw_instr(0, 12, 0xD0)
code_sw_instr(0, 13, 0xCC)
code_sw_instr(0, 14, 0xC8)
code_sw_instr(0, 15, 0xC4)
code_sw_instr(0, 16, 0xC0)
code_sw_instr(0, 17, 0xBC)
code_sw_instr(0, 18, 0xB8)
code_sw_instr(0, 19, 0xB4)
code_jal_instr(31, 0x0)