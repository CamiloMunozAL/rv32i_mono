/*
Modulo top-level del procesador RISC-V RV32I monociclo

Este módulo integra todos los componentes del procesador:
1. Program Counter (PC)
2. Sumador (PC + 4)
3. Instruction Memory (IM)
4. Control Unit (CU)
5. Register Unit (RU)
6. Immediate Generator (ImmGen)
7. Mux ALU A
8. Mux ALU B
9. Branch Unit (BRU)
10. ALU
11. Mux Next PC
12. Data Memory (DM)
13. Mux RU Data Write Source

Entradas:
- clk: Señal de reloj
- reset: Señal de reset

Salidas (para debug):
- pc_out: Valor actual del PC
- inst_out: Instrucción actual
- alu_result_out: Resultado de la ALU
- debug_ru: Registros para debug
- debug_dm: Memoria de datos para debug
*/

module monociclo (
    input  logic        clk,              // Reloj del sistema
    input  logic        reset,            // Reset del sistema
    
    // Salidas para debug
    output logic [31:0] pc_out,           // PC actual
    output logic [31:0] inst_out,         // Instrucción actual
    output logic [31:0] alu_result_out,   // Resultado de ALU
    output logic [31:0] alu_a_out,        // Entrada A de ALU
    output logic [31:0] alu_b_out,        // Entrada B de ALU
    output logic [31:0] next_pc_out,      // Siguiente PC
    output logic [31:0] debug_x1,         // Registros individuales
    output logic [31:0] debug_x2,
    output logic [31:0] debug_x3,
    output logic [31:0] debug_x4,
    output logic [31:0] debug_x5,
    output logic [31:0] debug_x6,
    output logic [31:0] debug_x7,
    output logic [31:0] debug_dm_word [0:7] // Primeros 8 words de memoria de datos
);

    //========================================================
    // SEÑALES INTERNAS
    //========================================================
    
    // Program Counter
    logic [31:0] pc_current;       // PC actual
    logic [31:0] pc_next;          // Siguiente valor del PC
    logic [31:0] pc_plus4;         // PC + 4
    
    // Instruction Memory
    logic [31:0] instruction;      // Instrucción leída
    
    // Control Unit signals
    logic        RUWr;             // Escribir en registro
    logic [2:0]  ImmSrc;           // Tipo de inmediato
    logic        AluAsrc;          // Selector entrada A de ALU
    logic        AluBsrc;          // Selector entrada B de ALU
    logic [4:0]  BrOp;             // Operación de branch
    logic [3:0]  AluOp;            // Operación de ALU
    logic        DmWr;             // Escribir en memoria de datos
    logic [2:0]  DmCtrl;           // Control de memoria de datos
    logic [1:0]  RUDataWrSrc;      // Selector de dato a escribir en RU
    
    // Register Unit
    logic [4:0]  rs1, rs2, rd;     // Direcciones de registros
    logic [31:0] ru_rs1_data;      // Dato leído de rs1
    logic [31:0] ru_rs2_data;      // Dato leído de rs2
    logic [31:0] ru_write_data;    // Dato a escribir en rd
    
    // Immediate Generator
    logic [31:0] immext;           // Inmediato extendido
    
    // ALU
    logic [31:0] alu_a;            // Entrada A de ALU
    logic [31:0] alu_b;            // Entrada B de ALU
    logic [31:0] alu_result;       // Resultado de ALU
    
    // Branch Unit
    logic        nextPCSrc;        // Selector de siguiente PC
    
    // Data Memory
    logic [31:0] dm_read_data;     // Dato leído de memoria
    
    //========================================================
    // EXTRACCIÓN DE CAMPOS DE LA INSTRUCCIÓN
    //========================================================
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign rd     = instruction[11:7];
    
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    
    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];
    
    //========================================================
    // SALIDAS DE DEBUG
    //========================================================
    assign pc_out = pc_current;
    assign inst_out = instruction;
    assign alu_result_out = alu_result;
    assign alu_a_out = alu_a;
    assign alu_b_out = alu_b;
    assign next_pc_out = pc_next;
    
    //========================================================
    // INSTANCIACIÓN DE MÓDULOS
    //========================================================
    
    // 1. Program Counter
    pc u_pc (
        .clk(clk),
        .reset(reset),
        .next_pc(pc_next),
        .pc_out(pc_current)
    );
    
    // 2. Sumador (PC + 4)
    sum u_sum (
        .pc_in(pc_current),
        .pc_out(pc_plus4)
    );
    
    // 3. Instruction Memory
    im u_im (
        .addr(pc_current),
        .inst(instruction)
    );
    
    // 4. Control Unit
    cu u_cu (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .RUWr(RUWr),
        .ImmSrc(ImmSrc),
        .AluAsrc(AluAsrc),
        .AluBsrc(AluBsrc),
        .BrOp(BrOp),
        .AluOp(AluOp),
        .DmWr(DmWr),
        .DmCtrl(DmCtrl),
        .RUDataWrSrc(RUDataWrSrc)
    );
    
    // 5. Register Unit
    ru u_ru (
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .DataWr(ru_write_data),
        .RUWr(RUWr),
        .RU_rs1(ru_rs1_data),
        .RU_rs2(ru_rs2_data),
        .debug_x1(debug_x1),
        .debug_x2(debug_x2),
        .debug_x3(debug_x3),
        .debug_x4(debug_x4),
        .debug_x5(debug_x5),
        .debug_x6(debug_x6),
        .debug_x7(debug_x7)
    );
    
    // 6. Immediate Generator
    immgen u_immgen (
        .inst(instruction),
        .immsrc(ImmSrc),
        .immext(immext)
    );
    
    // 7. Mux ALU A
    muxaluA u_muxaluA (
        .pc(pc_current),
        .ru_rs1(ru_rs1_data),
        .aluASrc(AluAsrc),
        .aluA(alu_a)
    );
    
    // 8. Mux ALU B
    muxaluB u_muxaluB (
        .immgen(immext),
        .ru_rs2(ru_rs2_data),
        .aluBSrc(AluBsrc),
        .aluB(alu_b)
    );
    
    // 9. Branch Unit
    bru u_bru (
        .ru_rs1(ru_rs1_data),
        .ru_rs2(ru_rs2_data),
        .brOp(BrOp),
        .nextPCSrc(nextPCSrc)
    );
    
    // 10. ALU
    alu u_alu (
        .A(alu_a),
        .B(alu_b),
        .ALUOp(AluOp),
        .ALURes(alu_result)
    );
    
    // 11. Mux Next PC
    muxnextpc u_muxnextpc (
        .pc_plus4(pc_plus4),
        .alu_result(alu_result),
        .nextPCSrc(nextPCSrc),
        .next_pc(pc_next)
    );
    
    // 12. Data Memory
    dm u_dm (
        .clk(clk),
        .DMWr(DmWr),
        .DMCtrl(DmCtrl),
        .addr(alu_result),
        .DataWr(ru_rs2_data),
        .DataRd(dm_read_data),
        .debug_dm_word(debug_dm_word)
    );
    
    // 13. Mux RU Data Write Source
    muxrudata u_muxrudata (
        .PCInc(pc_plus4),
        .ALURes(alu_result),
        .DataRd(dm_read_data),
        .RUDataWrSrc(RUDataWrSrc),
        .DataWr(ru_write_data)
    );

endmodule
