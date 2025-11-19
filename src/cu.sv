// 	4. Control unit
// 		a. Input: opcode, funct3, funct7
// 		b. Output:
// 			i. RUWr
// 			ii. ImmSrc
// 			iii. AluAsrc
// 			iv. AluBsrc
// 			v. BrOp
// 			vi. AluOp
// 			vii. Dmwr
// 			viii. DmCtrl
// 			ix. RUDataWrSrc
// Funcion: Decodifica instrucción y genera señales de control
/*
| Operación       | ALUOp |
| --------------- | ----- |
| **A + B**       | 0000  |
| **A - B**       | 1000  |
| **A << B**      | 0001  |
| **A < B**       | 0010  |
| **A < B (U)**   | 0011  |
| **A ⊕ B (XOR)** | 0100  |
| **A >> B**      | 0101  |
| **A >>> B**     | 1101  |
| **A ∨ B (OR)**  | 0110  |
| **A ∧ B (AND)** | 0111  |


Saltos:
| NextPCSrc |  BrOp | Significado                 | Condición de salto (Branch)     |
| :-------: | :---: | --------------------------- | ------------------------------- |
|     0     | 00XXX | No branch                   | —                               |
|           | 01000 | Igual (`=`)                 | beq (branch if equal)           |
|           | 01001 | Distinto (`≠`)              | bne (branch if not equal)       |
|           | 01100 | Menor (`<`) (signed)        | blt (branch if less than)       |
|           | 01101 | Mayor o igual (`≥`)         | bge (branch if greater/equal)   |
|           | 01110 | Menor (U) (`< (U)`)         | bltu (unsigned less than)       |
|           | 01111 | Mayor o igual (U) (`≥ (U)`) | bgeu (unsigned greater/equal)   |
|     1     | 1XXXX | Branch tomado               | Cualquier cond. de salto tomada |

*/


module cu(
  input logic [6:0] opcode,
  input logic [2:0] funct3,
  input logic [6:0] funct7,

  output logic RUWr, // RUWr este es 1 bit para la unidad de registro y dice si se va a escribir o no
  output logic [2:0] ImmSrc, // 3 bits para seleccionar el tipo de inmediato
  output logic AluAsrc, // 1 bit para seleccionar la fuente A de la ALU
  output logic AluBsrc, // 1 bit para seleccionar la fuente B de la
  output logic [4:0] BrOp, // 5 bits para la operación de branch
  output logic [3:0] AluOp, // 4 bits para la operación de la ALU
  output logic DmWr, // 1 bit para la escritura en memoria de datos
  output logic [2:0] DmCtrl, // 3 bits para el control de memoria de datos
  output logic [1:0] RUDataWrSrc // 2 bits para seleccionar la fuente de datos a escribir en la unidad de registro (10 desde sumador, 01 desde data memry y 00 desde ALU)
);

always_comb begin
  // Valores por defecto
  RUWr = 1'b0;
  ImmSrc = 3'b000;
  AluAsrc = 1'b0;
  AluBsrc = 1'b0;
  BrOp = 5'b00000;
  AluOp = 4'b0000;
  DmWr = 1'b0;
  DmCtrl = 3'b000;
  RUDataWrSrc = 2'b00;

  case (opcode)
    // R-Type Instructions
    7'b0110011: begin
      RUWr = 1'b1; // en las tipo R siempre se escribe en el registro
      ImmSrc = 3'b000; // No se usa inmediato en R-Type
      AluAsrc = 1'b0;// La fuente A es el registro rs1
      AluBsrc = 1'b0;// La fuente B es el registro rs2
      case (funct3)
        3'b000: begin
          if (funct7 == 7'b0000000)
            AluOp = 4'b0000; // ADD
          else if (funct7 == 7'b0100000)
            AluOp = 4'b1000; // SUB
          else
            AluOp = 4'b0000;
        end
        3'b001: AluOp = 4'b0001; // SLL
        3'b010: AluOp = 4'b0010; // SLT
        3'b011: AluOp = 4'b0011; // SLTU
        3'b100: AluOp = 4'b0100; // XOR
        3'b101: begin
          if (funct7 == 7'b0000000)
            AluOp = 4'b0101; // SRL
          else if (funct7 == 7'b0100000)
            AluOp = 4'b1101; // SRA
          else
            AluOp = 4'b0101;
        end
        3'b110: AluOp = 4'b0110; // OR
        3'b111: AluOp = 4'b0111; // AND
        default: AluOp = 4'b0000; // Operación por defecto
      endcase
    end


    // I-Type Instructions (e.g., ADDI, SLTI, etc.)
    7'b0010011: begin
      RUWr = 1'b1; // Se escribe en el registro
      ImmSrc = 3'b000; // I-Type immediate
      AluAsrc = 1'b0; // La fuente A es el registro rs1
      AluBsrc = 1'b1; // La fuente B es el inmediato
      case (funct3)
        3'b000: AluOp = 4'b0000; // ADDI
        3'b010: AluOp = 4'b0010; // SLTI
        3'b011: AluOp = 4'b0011; // SLTIU
        3'b100: AluOp = 4'b0100; // XORI
        3'b110: AluOp = 4'b0110; // ORI
        3'b111: AluOp = 4'b0111; // ANDI
        3'b001: begin
          if (funct7 == 7'b0000000)
            AluOp = 4'b0001; // SLLI
          else
            AluOp = 4'b0000; // Operación por defecto
        end
        3'b101: begin
          if (funct7 == 7'b0000000)
            AluOp = 4'b0101; // SRLI
          else if (funct7 == 7'b0100000)
            AluOp = 4'b1101; // SRAI
          else
            AluOp = 4'b0000; // Operación por defecto
        end
        default: AluOp = 4'b0000; // Operación por defecto
      endcase
    end

    // Load Instructions (I-Type)
    7'b0000011: begin
      RUWr = 1'b1; // Se escribe en el registro
      ImmSrc = 3'b000; // I-Type immediate
      AluAsrc = 1'b0; // La fuente A es el registro rs1
      AluBsrc = 1'b1; // La fuente B es el inmediato
      AluOp = 4'b0000; // ADD para calcular la dirección
      DmWr = 1'b0; // No se escribe en memoria
      case (funct3)
        3'b000: DmCtrl = 3'b000; // LB
        3'b001: DmCtrl = 3'b001; // LH
        3'b010: DmCtrl = 3'b010; // LW
        3'b100: DmCtrl = 3'b100; // LBU
        3'b101: DmCtrl = 3'b101; // LHU
        default: DmCtrl = 3'b000; // Control por defecto
      endcase
      RUDataWrSrc = 2'b01; // Datos desde memoria
    end

    // Store Instructions (S-Type)
    7'b0100011: begin
      RUWr = 1'b0; // No se escribe en el registro
      ImmSrc = 3'b001; // S-Type immediate
      AluAsrc = 1'b0; // La fuente A es el registro rs1
      AluBsrc = 1'b1; // La fuente B es el inmediato
      AluOp = 4'b0000; // ADD para calcular la dirección
      DmWr = 1'b1; // Se escribe en memoria
      case (funct3)
        3'b000: DmCtrl = 3'b000; // SB
        3'b001: DmCtrl = 3'b001; // SH
        3'b010: DmCtrl = 3'b010; // SW
        default: DmCtrl = 3'b000; // Control por defecto
      endcase
    end

    // Branch Instructions (B-Type)
    7'b1100011: begin
      RUWr = 1'b0; // No se escribe en el registro
      ImmSrc = 3'b010; // B-Type immediate
      AluAsrc = 1'b0; // La fuente A es el registro rs1
      AluBsrc = 1'b0; // La fuente B es el registro rs2
      AluOp = 4'b1000; // SUB para comparar
      case (funct3)
        3'b000: BrOp = 5'b01000; // BEQ
        3'b001: BrOp = 5'b01001; // BNE
        3'b100: BrOp = 5'b01100; // BLT
        3'b101: BrOp = 5'b01101; // BGE
        3'b110: BrOp = 5'b01110; // BLTU
        3'b111: BrOp = 5'b01111; // BGEU
        default: BrOp = 5'b00000; // No branch
      endcase
    end

    // JAL Instruction (J-Type)
    7'b1101111: begin
      RUWr = 1'b1; // Se escribe en el registro
      ImmSrc = 3'b100; // J-Type immediate
      AluAsrc = 1'b1; // Fuente A es PC
      AluBsrc = 1'b1; // Fuente B es inmediato
      AluOp = 4'b0000; // ADD para calcular la dirección de salto
      BrOp = 5'b10000; // Salto incondicional
      RUDataWrSrc = 2'b10; // Datos desde el sumador (PC + 4)
    end
    // JALR Instruction (I-Type)
    7'b1100111: begin
      RUWr = 1'b1; // Se escribe en el registro
      ImmSrc = 3'b000; // I-Type immediate
      AluAsrc = 1'b0; // Fuente A es rs1
      AluBsrc = 1'b1; // Fuente B es inmediato
      AluOp = 4'b0000; // ADD para calcular la dirección de salto
      BrOp = 5'b10000; // Salto incondicional
      RUDataWrSrc = 2'b10; // Datos desde el sumador (PC + 4)
    end

    // LUI Instruction (U-Type)
    7'b0110111: begin
      RUWr = 1'b1; // Se escribe en el registro
      ImmSrc = 3'b011; // U-Type immediate
      AluAsrc = 1'b1; // Fuente A es 0 (o PC, depende de tu implementación)
      AluBsrc = 1'b1; // Fuente B es inmediato
      AluOp = 4'b0000; // ADD para cargar el inmediato
      RUDataWrSrc = 2'b00; // Datos desde la ALU
    end
    // AUIPC Instruction (U-Type)
    7'b0010111: begin
      RUWr = 1'b1; // Se escribe en el registro
      ImmSrc = 3'b011; // U-Type immediate
      AluAsrc = 1'b1; // Fuente A es PC
      AluBsrc = 1'b1; // Fuente B es inmediato
      AluOp = 4'b0000; // ADD para calcular la dirección
      RUDataWrSrc = 2'b00; // Datos desde la ALU
    end    

    // Agregar más casos para otros tipos de instrucciones (I-Type, S-Type, B-Type, U-Type, J-Type)

    default: begin
      // Valores por defecto ya establecidos
    end
  endcase
end
endmodule

  