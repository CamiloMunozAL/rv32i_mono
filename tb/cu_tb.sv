`timescale 1ns/1ps

module cu_tb;

  // Señales de entrada
  logic [6:0] opcode;
  logic [2:0] funct3;
  logic [6:0] funct7;

  // Señales de salida
  logic RUWr;
  logic [2:0] ImmSrc;
  logic AluAsrc;
  logic AluBsrc;
  logic [4:0] BrOp;
  logic [3:0] AluOp;
  logic DmWr;
  logic [2:0] DmCtrl;
  logic [1:0] RUDataWrSrc;

  // Instancia del DUT (Device Under Test)
  cu dut (
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

  // Contador de errores
  integer errors = 0;
  integer test_num = 0;

  // Task para verificar resultados
  task check_outputs(
    input string test_name,
    input logic exp_RUWr,
    input logic [2:0] exp_ImmSrc,
    input logic exp_AluAsrc,
    input logic exp_AluBsrc,
    input logic [4:0] exp_BrOp,
    input logic [3:0] exp_AluOp,
    input logic exp_DmWr,
    input logic [2:0] exp_DmCtrl,
    input logic [1:0] exp_RUDataWrSrc
  );
    test_num++;
    #1; // Pequeño delay para estabilizar las señales
    
    if (RUWr !== exp_RUWr || ImmSrc !== exp_ImmSrc || AluAsrc !== exp_AluAsrc ||
        AluBsrc !== exp_AluBsrc || BrOp !== exp_BrOp || AluOp !== exp_AluOp ||
        DmWr !== exp_DmWr || DmCtrl !== exp_DmCtrl || RUDataWrSrc !== exp_RUDataWrSrc) begin
      
      $display("❌ Test #%0d FAILED: %s", test_num, test_name);
      $display("   opcode=%b, funct3=%b, funct7=%b", opcode, funct3, funct7);
      
      if (RUWr !== exp_RUWr)
        $display("   RUWr: expected=%b, got=%b", exp_RUWr, RUWr);
      if (ImmSrc !== exp_ImmSrc)
        $display("   ImmSrc: expected=%b, got=%b", exp_ImmSrc, ImmSrc);
      if (AluAsrc !== exp_AluAsrc)
        $display("   AluAsrc: expected=%b, got=%b", exp_AluAsrc, AluAsrc);
      if (AluBsrc !== exp_AluBsrc)
        $display("   AluBsrc: expected=%b, got=%b", exp_AluBsrc, AluBsrc);
      if (BrOp !== exp_BrOp)
        $display("   BrOp: expected=%b, got=%b", exp_BrOp, BrOp);
      if (AluOp !== exp_AluOp)
        $display("   AluOp: expected=%b, got=%b", exp_AluOp, AluOp);
      if (DmWr !== exp_DmWr)
        $display("   DmWr: expected=%b, got=%b", exp_DmWr, DmWr);
      if (DmCtrl !== exp_DmCtrl)
        $display("   DmCtrl: expected=%b, got=%b", exp_DmCtrl, DmCtrl);
      if (RUDataWrSrc !== exp_RUDataWrSrc)
        $display("   RUDataWrSrc: expected=%b, got=%b", exp_RUDataWrSrc, RUDataWrSrc);
      
      errors++;
    end else begin
      $display("✅ Test #%0d PASSED: %s", test_num, test_name);
    end
  endtask

  initial begin
    $display("=================================================================");
    $display("            TESTBENCH PARA CONTROL UNIT RV32I");
    $display("=================================================================\n");

    // Inicializar señales
    opcode = 7'b0;
    funct3 = 3'b0;
    funct7 = 7'b0;
    #10;

    $display("\n--- Probando Instrucciones R-Type ---");
    
    // ADD (funct3=000, funct7=0000000)
    opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0000000;
    check_outputs("ADD", 1'b1, 3'b000, 1'b0, 1'b0, 5'b00000, 4'b0000, 1'b0, 3'b000, 2'b00);
    #10;

    // SUB (funct3=000, funct7=0100000)
    opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0100000;
    check_outputs("SUB", 1'b1, 3'b000, 1'b0, 1'b0, 5'b00000, 4'b1000, 1'b0, 3'b000, 2'b00);
    #10;

    // SLL (funct3=001, funct7=0000000)
    opcode = 7'b0110011; funct3 = 3'b001; funct7 = 7'b0000000;
    check_outputs("SLL", 1'b1, 3'b000, 1'b0, 1'b0, 5'b00000, 4'b0001, 1'b0, 3'b000, 2'b00);
    #10;

    // SLT (funct3=010, funct7=0000000)
    opcode = 7'b0110011; funct3 = 3'b010; funct7 = 7'b0000000;
    check_outputs("SLT", 1'b1, 3'b000, 1'b0, 1'b0, 5'b00000, 4'b0010, 1'b0, 3'b000, 2'b00);
    #10;

    // SLTU (funct3=011, funct7=0000000)
    opcode = 7'b0110011; funct3 = 3'b011; funct7 = 7'b0000000;
    check_outputs("SLTU", 1'b1, 3'b000, 1'b0, 1'b0, 5'b00000, 4'b0011, 1'b0, 3'b000, 2'b00);
    #10;

    // XOR (funct3=100, funct7=0000000)
    opcode = 7'b0110011; funct3 = 3'b100; funct7 = 7'b0000000;
    check_outputs("XOR", 1'b1, 3'b000, 1'b0, 1'b0, 5'b00000, 4'b0100, 1'b0, 3'b000, 2'b00);
    #10;

    // SRL (funct3=101, funct7=0000000)
    opcode = 7'b0110011; funct3 = 3'b101; funct7 = 7'b0000000;
    check_outputs("SRL", 1'b1, 3'b000, 1'b0, 1'b0, 5'b00000, 4'b0101, 1'b0, 3'b000, 2'b00);
    #10;

    // SRA (funct3=101, funct7=0100000)
    opcode = 7'b0110011; funct3 = 3'b101; funct7 = 7'b0100000;
    check_outputs("SRA", 1'b1, 3'b000, 1'b0, 1'b0, 5'b00000, 4'b1101, 1'b0, 3'b000, 2'b00);
    #10;

    // OR (funct3=110, funct7=0000000)
    opcode = 7'b0110011; funct3 = 3'b110; funct7 = 7'b0000000;
    check_outputs("OR", 1'b1, 3'b000, 1'b0, 1'b0, 5'b00000, 4'b0110, 1'b0, 3'b000, 2'b00);
    #10;

    // AND (funct3=111, funct7=0000000)
    opcode = 7'b0110011; funct3 = 3'b111; funct7 = 7'b0000000;
    check_outputs("AND", 1'b1, 3'b000, 1'b0, 1'b0, 5'b00000, 4'b0111, 1'b0, 3'b000, 2'b00);
    #10;

    $display("\n--- Probando Instrucciones I-Type (Aritméticas) ---");

    // ADDI
    opcode = 7'b0010011; funct3 = 3'b000; funct7 = 7'b0000000;
    check_outputs("ADDI", 1'b1, 3'b000, 1'b0, 1'b1, 5'b00000, 4'b0000, 1'b0, 3'b000, 2'b00);
    #10;

    // SLTI
    opcode = 7'b0010011; funct3 = 3'b010; funct7 = 7'b0000000;
    check_outputs("SLTI", 1'b1, 3'b000, 1'b0, 1'b1, 5'b00000, 4'b0010, 1'b0, 3'b000, 2'b00);
    #10;

    // SLTIU
    opcode = 7'b0010011; funct3 = 3'b011; funct7 = 7'b0000000;
    check_outputs("SLTIU", 1'b1, 3'b000, 1'b0, 1'b1, 5'b00000, 4'b0011, 1'b0, 3'b000, 2'b00);
    #10;

    // XORI
    opcode = 7'b0010011; funct3 = 3'b100; funct7 = 7'b0000000;
    check_outputs("XORI", 1'b1, 3'b000, 1'b0, 1'b1, 5'b00000, 4'b0100, 1'b0, 3'b000, 2'b00);
    #10;

    // ORI
    opcode = 7'b0010011; funct3 = 3'b110; funct7 = 7'b0000000;
    check_outputs("ORI", 1'b1, 3'b000, 1'b0, 1'b1, 5'b00000, 4'b0110, 1'b0, 3'b000, 2'b00);
    #10;

    // ANDI
    opcode = 7'b0010011; funct3 = 3'b111; funct7 = 7'b0000000;
    check_outputs("ANDI", 1'b1, 3'b000, 1'b0, 1'b1, 5'b00000, 4'b0111, 1'b0, 3'b000, 2'b00);
    #10;

    // SLLI
    opcode = 7'b0010011; funct3 = 3'b001; funct7 = 7'b0000000;
    check_outputs("SLLI", 1'b1, 3'b000, 1'b0, 1'b1, 5'b00000, 4'b0001, 1'b0, 3'b000, 2'b00);
    #10;

    // SRLI
    opcode = 7'b0010011; funct3 = 3'b101; funct7 = 7'b0000000;
    check_outputs("SRLI", 1'b1, 3'b000, 1'b0, 1'b1, 5'b00000, 4'b0101, 1'b0, 3'b000, 2'b00);
    #10;

    // SRAI
    opcode = 7'b0010011; funct3 = 3'b101; funct7 = 7'b0100000;
    check_outputs("SRAI", 1'b1, 3'b000, 1'b0, 1'b1, 5'b00000, 4'b1101, 1'b0, 3'b000, 2'b00);
    #10;

    $display("\n--- Probando Instrucciones Load ---");

    // LB
    opcode = 7'b0000011; funct3 = 3'b000; funct7 = 7'b0000000;
    check_outputs("LB", 1'b1, 3'b000, 1'b0, 1'b1, 5'b00000, 4'b0000, 1'b0, 3'b000, 2'b01);
    #10;

    // LH
    opcode = 7'b0000011; funct3 = 3'b001; funct7 = 7'b0000000;
    check_outputs("LH", 1'b1, 3'b000, 1'b0, 1'b1, 5'b00000, 4'b0000, 1'b0, 3'b001, 2'b01);
    #10;

    // LW
    opcode = 7'b0000011; funct3 = 3'b010; funct7 = 7'b0000000;
    check_outputs("LW", 1'b1, 3'b000, 1'b0, 1'b1, 5'b00000, 4'b0000, 1'b0, 3'b010, 2'b01);
    #10;

    // LBU
    opcode = 7'b0000011; funct3 = 3'b100; funct7 = 7'b0000000;
    check_outputs("LBU", 1'b1, 3'b000, 1'b0, 1'b1, 5'b00000, 4'b0000, 1'b0, 3'b100, 2'b01);
    #10;

    // LHU
    opcode = 7'b0000011; funct3 = 3'b101; funct7 = 7'b0000000;
    check_outputs("LHU", 1'b1, 3'b000, 1'b0, 1'b1, 5'b00000, 4'b0000, 1'b0, 3'b101, 2'b01);
    #10;

    $display("\n--- Probando Instrucciones Store ---");

    // SB
    opcode = 7'b0100011; funct3 = 3'b000; funct7 = 7'b0000000;
    check_outputs("SB", 1'b0, 3'b001, 1'b0, 1'b1, 5'b00000, 4'b0000, 1'b1, 3'b000, 2'b00);
    #10;

    // SH
    opcode = 7'b0100011; funct3 = 3'b001; funct7 = 7'b0000000;
    check_outputs("SH", 1'b0, 3'b001, 1'b0, 1'b1, 5'b00000, 4'b0000, 1'b1, 3'b001, 2'b00);
    #10;

    // SW
    opcode = 7'b0100011; funct3 = 3'b010; funct7 = 7'b0000000;
    check_outputs("SW", 1'b0, 3'b001, 1'b0, 1'b1, 5'b00000, 4'b0000, 1'b1, 3'b010, 2'b00);
    #10;

    $display("\n--- Probando Instrucciones Branch ---");

    // BEQ
    opcode = 7'b1100011; funct3 = 3'b000; funct7 = 7'b0000000;
    check_outputs("BEQ", 1'b0, 3'b010, 1'b0, 1'b0, 5'b01000, 4'b1000, 1'b0, 3'b000, 2'b00);
    #10;

    // BNE
    opcode = 7'b1100011; funct3 = 3'b001; funct7 = 7'b0000000;
    check_outputs("BNE", 1'b0, 3'b010, 1'b0, 1'b0, 5'b01001, 4'b1000, 1'b0, 3'b000, 2'b00);
    #10;

    // BLT
    opcode = 7'b1100011; funct3 = 3'b100; funct7 = 7'b0000000;
    check_outputs("BLT", 1'b0, 3'b010, 1'b0, 1'b0, 5'b01100, 4'b1000, 1'b0, 3'b000, 2'b00);
    #10;

    // BGE
    opcode = 7'b1100011; funct3 = 3'b101; funct7 = 7'b0000000;
    check_outputs("BGE", 1'b0, 3'b010, 1'b0, 1'b0, 5'b01101, 4'b1000, 1'b0, 3'b000, 2'b00);
    #10;

    // BLTU
    opcode = 7'b1100011; funct3 = 3'b110; funct7 = 7'b0000000;
    check_outputs("BLTU", 1'b0, 3'b010, 1'b0, 1'b0, 5'b01110, 4'b1000, 1'b0, 3'b000, 2'b00);
    #10;

    // BGEU
    opcode = 7'b1100011; funct3 = 3'b111; funct7 = 7'b0000000;
    check_outputs("BGEU", 1'b0, 3'b010, 1'b0, 1'b0, 5'b01111, 4'b1000, 1'b0, 3'b000, 2'b00);
    #10;

    $display("\n--- Probando Instrucciones Jump ---");

    // JAL
    opcode = 7'b1101111; funct3 = 3'b000; funct7 = 7'b0000000;
    check_outputs("JAL", 1'b1, 3'b100, 1'b1, 1'b1, 5'b10000, 4'b0000, 1'b0, 3'b000, 2'b10);
    #10;

    // JALR
    opcode = 7'b1100111; funct3 = 3'b000; funct7 = 7'b0000000;
    check_outputs("JALR", 1'b1, 3'b000, 1'b0, 1'b1, 5'b10000, 4'b0000, 1'b0, 3'b000, 2'b10);
    #10;

    $display("\n--- Probando Instrucciones U-Type ---");

    // LUI
    opcode = 7'b0110111; funct3 = 3'b000; funct7 = 7'b0000000;
    check_outputs("LUI", 1'b1, 3'b011, 1'b1, 1'b1, 5'b00000, 4'b0000, 1'b0, 3'b000, 2'b00);
    #10;

    // AUIPC
    opcode = 7'b0010111; funct3 = 3'b000; funct7 = 7'b0000000;
    check_outputs("AUIPC", 1'b1, 3'b011, 1'b1, 1'b1, 5'b00000, 4'b0000, 1'b0, 3'b000, 2'b00);
    #10;

    $display("\n--- Probando Caso Default ---");

    // Opcode inválido
    opcode = 7'b1111111; funct3 = 3'b111; funct7 = 7'b1111111;
    check_outputs("INVALID", 1'b0, 3'b000, 1'b0, 1'b0, 5'b00000, 4'b0000, 1'b0, 3'b000, 2'b00);
    #10;

    // Resumen final
    $display("\n=================================================================");
    $display("                     RESUMEN DE PRUEBAS");
    $display("=================================================================");
    $display("Total de tests: %0d", test_num);
    $display("Tests pasados: %0d", test_num - errors);
    $display("Tests fallidos: %0d", errors);
    
    if (errors == 0) begin
      $display("\n🎉 ¡TODOS LOS TESTS PASARON EXITOSAMENTE! 🎉");
    end else begin
      $display("\n⚠️  ALGUNOS TESTS FALLARON ⚠️");
    end
    $display("=================================================================\n");

    $finish;
  end

  // Generación de archivo VCD para visualización
  initial begin
     $dumpfile("vcd/cu_tb.vcd");
    $dumpvars(0, cu_tb);
  end

endmodule
