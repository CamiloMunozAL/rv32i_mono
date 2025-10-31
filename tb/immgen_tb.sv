/*
Testbench para el módulo immgen con instrucciones variadas y valores no triviales.

I: 000 (I-Type, ejemplo: addi x5, x0, 3)
S: 001 (S-Type, ejemplo: sw x5, 20(x2))
B: 101 (B-Type, ejemplo: beq x2, x6, -16)
U: 010 (U-Type, ejemplo: lui x10, 0x12345)
J: 011 (J-Type, ejemplo: jal x1, 0x1F4)
*/

module immgen_tb;
  // Señales internas
  logic [31:0] inst;
  logic [2:0] immsrc;
  logic signed [31:0] immext;

  // Instancia del módulo immgen
  immgen uut (
    .inst(inst),
    .immsrc(immsrc),
    .immext(immext)
  );

  initial begin
    $dumpfile("vcd/immgen_tb.vcd");
    $dumpvars(0, immgen_tb);
    $display("=================================================================");
    $display("            TESTBENCH PARA IMMEDIATE GENERATOR (immgen)");
    $display("=================================================================\n");

    // -----------------------------------------------------------
    // Prueba I-Type: addi x5, x0, 3 --> inst = 0x00300293
    // addi x5, x0, 3 => opcode=0010011, funct3=000, rd=5, rs1=0, imm=3
    // binario: 0000_0000_0011_00000_000_00101_0010011
    // -----------------------------------------------------------
    inst = 32'h00300293;
    immsrc = 3'b000;
    #10;
    $display("I-Type (ADDI x5, x0, 3) Imm: 0x%h (debe ser 0x00000003)", immext);

    // -----------------------------------------------------------
    // Prueba S-Type: sw x5, 20(x2) --> inst = 0x01412223
    // sw x5, 20(x2) => opcode=0100011, funct3=010, rs1=2, rs2=5, imm=20
    // binario: 0000_0001_0100_00010_010_10100_0100011
    // [imm[11:5]]=0000001, [rs2]=0101, [rs1]=00010, [funct3]=010, [imm[4:0]]=10100, [opcode]=0100011
    // -----------------------------------------------------------
    inst = 32'h01412223;
    immsrc = 3'b001;
    #10;
    $display("S-Type (SW x5, 20(x2)) Imm: 0x%h (debe ser 0x00000014)", immext);

    // -----------------------------------------------------------
    // Prueba B-Type: beq x2, x6, -16 --> inst = 0xFE610AE3
    // beq x2, x6, -16 => opcode=1100011, funct3=000, rs1=2, rs2=6, imm=-16
    // binario: 1111_1110_0110_00010_000_01100_10100011
    // (inmediato negativo, prueba de extensión de signo)
    // -----------------------------------------------------------
    inst = 32'hFE610AE3;
    immsrc = 3'b101;
    #10;
    $display("B-Type (BEQ x2, x6, -16) Imm: 0x%h (debe ser 0xFFFFFFF0)", immext);

    // -----------------------------------------------------------
    // Prueba U-Type: lui x10, 0x12345 --> inst = 0x123450B7
    // lui x10, 0x12345 => opcode=0110111, rd=10, imm=0x12345
    // binario: 0001_0010_0011_0100_0101_0000_1011_0111
    // El inmediato es 0x12345000
    // -----------------------------------------------------------
    inst = 32'h123450B7;
    immsrc = 3'b010;
    #10;
    $display("U-Type (LUI x10, 0x12345) Imm: 0x%h (debe ser 0x12345000)", immext);

    // -----------------------------------------------------------
    // Prueba J-Type: jal x1, 0x1F4 --> inst = 0x1F4000EF
    // jal x1, 0x1F4 => opcode=1101111, rd=1, imm=0x1F4
    // binario: 0001_1111_0100_0000_0000_0000_1110_1111
    // El inmediato es 0x000001F4
    // -----------------------------------------------------------
    inst = 32'h1F4000EF;
    immsrc = 3'b011;
    #10;
    $display("J-Type (JAL x1, 0x1F4) Imm: 0x%h (debe ser 0x000001F4)", immext);

    $finish;
  end
endmodule
