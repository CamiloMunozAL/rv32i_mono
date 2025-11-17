/* Testbech para la unidad de saltos (BRU)
Modulo de la unidad branch (BRU)
inputs:
- ru[rs1] de 32 bits desde la unidad de registros
- ru[rs2] de 32 bits desde la unidad de registros
outputs:
- 1 bit de señal de branch (BrTaken) hacia mux para el program counter
control:
- 5 bits para seleccionar el tipo de branch (BrOp) desde la unidad de control

nextPCSrc -> BrOp
0 -> 00XXX
= -> 01000
!= -> 01001
< -> 01100
>= -> 01101
<u -> 01110
>=u -> 01111
1 -> 1XXXX

*/
module bru_tb;
  // Señales internas
  logic [31:0] ru_rs1;
  logic [31:0] ru_rs2;
  logic [4:0] brOp;
  logic nextPCSrc;

  // Instancia del módulo bru
  bru uut (
    .ru_rs1(ru_rs1),
    .ru_rs2(ru_rs2),
    .brOp(brOp),
    .nextPCSrc(nextPCSrc)
  );

  initial begin
    $dumpfile("vcd/bru_tb.vcd");
    $dumpvars(0, bru_tb);
    $display("=================================================================");
    $display("            TESTBENCH PARA BRANCH UNIT (BRU)");
    $display("=================================================================\n");

    // -----------------------------------------------------------
    // Prueba 0: BEQ - Igualdad (caso negativo)
    // ru_rs1 = 10, ru_rs2 = 20, brOp = 01000 (BEQ)
    // -----------------------------------------------------------
    ru_rs1 = 32'd10;
    ru_rs2 = 32'd20;
    brOp = 5'b01000; // BEQ
    #10;
    $display("BEQ Test (negativo): ru_rs1 = %d, ru_rs2 = %d, nextPCSrc = %b (debe ser 0)", ru_rs1, ru_rs2, nextPCSrc);

    // -----------------------------------------------------------
    // Prueba 1: BEQ - Igualdad
    // ru_rs1 = 10, ru_rs2 = 10, brOp = 01000 (BEQ)
    // -----------------------------------------------------------
    ru_rs1 = 32'd10;
    ru_rs2 = 32'd10;
    brOp = 5'b01000; // BEQ
    #10;
    $display("BEQ Test: ru_rs1 = %d, ru_rs2 = %d, nextPCSrc = %b (debe ser 1)", ru_rs1, ru_rs2, nextPCSrc);

    // -----------------------------------------------------------
    // Prueba 2: BNE - Desigualdad
    // ru_rs1 = 15, ru_rs2 = 20, brOp = 01001 (BNE)
    // -----------------------------------------------------------
    ru_rs1 = 32'd15;
    ru_rs2 = 32'd20;
    brOp = 5'b01001; // BNE
    #10;
    $display("BNE Test: ru_rs1 = %d, ru_rs2 = %d, nextPCSrc = %b (debe ser 1)", ru_rs1, ru_rs2, nextPCSrc);

    // -----------------------------------------------------------
    // Prueba 3: BLT - Menor que (signed)
    // ru_rs1 = -5, ru_rs2 = 10, brOp = 01100 (BLT)
    // -----------------------------------------------------------
    ru_rs1 = -32'sd5;
    ru_rs2 = 32'd10;
    brOp = 5'b01100; // BLT
    #10;
    $display("BLT Test: ru_rs1 = %d, ru_rs2 = %d, nextPCSrc = %b (debe ser 1)", ru_rs1, ru_rs2, nextPCSrc);

    // -----------------------------------------------------------
    // Prueba 4: BGE - Mayor o igual que (signed)
    // ru_rs1 = 10, ru_rs2 = 10, brOp = 01101 (BGE)
    // -----------------------------------------------------------
    ru_rs1 = 32'd10;
    ru_rs2 = 32'd10;
    brOp = 5'b01101; // BGE
    #10;
    $display("BGE Test: ru_rs1 = %d, ru_rs2 = %d, nextPCSrc = %b (debe ser 1)", ru_rs1, ru_rs2, nextPCSrc);

    // -----------------------------------------------------------
    // Prueba 5: BLTU - Menor que (unsigned)
    // ru_rs1 = 5, ru_rs2 = 10, brOp = 01110 (BLTU)
    // -----------------------------------------------------------
    ru_rs1 = 32'd5;
    ru_rs2 = 32'd10;
    brOp = 5'b01110; // BLTU
    #10;
    $display("BLTU Test: ru_rs1 = %d, ru_rs2 = %d, nextPCSrc = %b (debe ser 1)", ru_rs1, ru_rs2, nextPCSrc);
    // -----------------------------------------------------------
    // Prueba 6: BGEU - Mayor o igual que (unsigned)
    // ru_rs1 = 20, ru_rs2 = 10, brOp = 01111 (BGEU)
    // -----------------------------------------------------------
    ru_rs1 = 32'd20;
    ru_rs2 = 32'd10;
    brOp = 5'b01111; // BGEU
    #10;
    $display("BGEU Test: ru_rs1 = %d, ru_rs2 = %d, nextPCSrc = %b (debe ser 1)", ru_rs1, ru_rs2, nextPCSrc);

    // -----------------------------------------------------------
    // Prueba 7: desde el Program counter (sin branch)
    // ru_rs1 = 0, ru_rs2 = 0, brOp = 00000 (No branch)
    // -----------------------------------------------------------
    ru_rs1 = 32'd0;
    ru_rs2 = 32'd0;
    brOp = 5'b00000; // No branch
    #10;
    $display("No Branch Test: ru_rs1 = %d, ru_rs2 = %d, nextPCSrc = %b (debe ser 0)", ru_rs1, ru_rs2, nextPCSrc);

    $display("\n=================================================================");
    $display("                     FIN DE SIMULACIÓN");
    $display("=================================================================");
    #20 $finish;
  end
endmodule