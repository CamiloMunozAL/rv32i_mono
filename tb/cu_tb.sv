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
    #10;
    $display("ADD: RUWr=%b, AluOp=%b", RUWr, AluOp);

    // SUB (funct3=000, funct7=0100000)
    opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0100000;
    #10;
    $display("SUB: RUWr=%b, AluOp=%b", RUWr, AluOp);

    $display("\n--- Probando Instrucciones I-Type ---");

    // ADDI
    opcode = 7'b0010011; funct3 = 3'b000; funct7 = 7'b0000000;
    #10;
    $display("ADDI: RUWr=%b, AluOp=%b", RUWr, AluOp);

    // SLTI
    opcode = 7'b0010011; funct3 = 3'b010; funct7 = 7'b0000000;
    #10;
    $display("SLTI: RUWr=%b, AluOp=%b", RUWr, AluOp);

    $display("\n--- Probando Instrucciones Load ---");

    // LW
    opcode = 7'b0000011; funct3 = 3'b010; funct7 = 7'b0000000;
    #10;
    $display("LW: RUWr=%b, DmCtrl=%b", RUWr, DmCtrl);

    $display("\n--- Probando Instrucciones Store ---");

    // SW
    opcode = 7'b0100011; funct3 = 3'b010; funct7 = 7'b0000000;
    #10;
    $display("SW: DmWr=%b, DmCtrl=%b", DmWr, DmCtrl);

    $display("\n--- Probando Instrucciones Branch ---");

    // BEQ
    opcode = 7'b1100011; funct3 = 3'b000; funct7 = 7'b0000000;
    #10;
    $display("BEQ: BrOp=%b", BrOp);

    $display("\n--- Probando Instrucciones Jump ---");

    // JAL
    opcode = 7'b1101111; funct3 = 3'b000; funct7 = 7'b0000000;
    #10;
    $display("JAL: RUWr=%b, BrOp=%b", RUWr, BrOp);

    $display("\n--- Probando Caso Default ---");

    // Opcode inválido
    opcode = 7'b1111111; funct3 = 3'b111; funct7 = 7'b1111111;
    #10;
    $display("INVALID: RUWr=%b, AluOp=%b", RUWr, AluOp);

    $display("\n=================================================================");
    $display("                     FIN DE PRUEBAS");
    $display("=================================================================");
    $finish;
  end

  // Generación de archivo VCD para visualización
  initial begin
    $dumpfile("vcd/cu_tb.vcd");
    $dumpvars(0, cu_tb);
  end

endmodule