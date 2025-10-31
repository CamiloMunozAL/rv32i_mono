// Testbench para la unidad de registros (RU)
`timescale 1ns / 1ps

module ru_tb;
  // Señales internas
  logic clk;
  logic [4:0] rs1, rs2, rd;
  logic [31:0] DataWr;
  logic RUWr;
  logic [31:0] RU_rs1, RU_rs2;

  // Instancia del módulo RU
  ru uut (
    .clk(clk),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .DataWr(DataWr),
    .RUWr(RUWr),
    .RU_rs1(RU_rs1),
    .RU_rs2(RU_rs2)
  );

  // Generación de reloj
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $dumpfile("vcd/ru_tb.vcd");
    $dumpvars(0, ru_tb);
    $display("=================================================================");
    $display("            TESTBENCH PARA REGISTER UNIT (RU)");
    $display("=================================================================\n");

    // Inicializar señales
    rs1 = 5'd0; rs2 = 5'd0; rd = 5'd0; DataWr = 32'd0; RUWr = 1'b0;
    #10;

    $display("\n--- Prueba 1: Lectura asíncrona de x0 y x2 (Stack Pointer) ---");
    rs1 = 5'd0; rs2 = 5'd2;
    #2;
    $display("x0 = 0x%h (debe ser 0x00000000)", RU_rs1);
    $display("x2 = 0x%h (debe ser 0xFFFFFFFF)", RU_rs2);

    $display("\n--- Prueba 2: Escritura síncrona en x5 ---");
    @(posedge clk);
    rd = 5'd5; DataWr = 32'hA5A5A5A5; RUWr = 1'b1;
    $display("Escribiendo 0xA5A5A5A5 en x5...");
    @(posedge clk);
    RUWr = 1'b0; rs1 = 5'd5;
    #2;
    $display("x5 = 0x%h (debe ser 0xA5A5A5A5)", RU_rs1);

    $display("\n--- Prueba 3: Protección de x0 (intento de escritura) ---");
    @(posedge clk);
    rd = 5'd0; DataWr = 32'hDEADBEEF; RUWr = 1'b1;
    $display("Intentando escribir 0xDEADBEEF en x0...");
    @(posedge clk);
    RUWr = 1'b0; rs1 = 5'd0;
    #2;
    $display("x0 = 0x%h (debe permanecer 0x00000000)", RU_rs1);

    $display("\n--- Prueba 4: Escrituras múltiples y lectura simultánea ---");
    @(posedge clk);
    rd = 5'd10; DataWr = 32'h12345678; RUWr = 1'b1;
    @(posedge clk);
    rd = 5'd15; DataWr = 32'h87654321; RUWr = 1'b1;
    @(posedge clk);
    @(posedge clk);
    RUWr = 1'b0;
    rs1 = 5'd10; rs2 = 5'd15;
    #2;
    $display("x10 = 0x%h (debe ser 0x12345678)", RU_rs1);
    $display("x15 = 0x%h (debe ser 0x87654321)", RU_rs2);

    $display("\n--- Prueba 5: Sobrescritura de un registro ---");
    @(posedge clk);
    rd = 5'd5; DataWr = 32'h0000FFFF; RUWr = 1'b1;
    $display("Sobrescribiendo x5 con 0x0000FFFF...");
    @(posedge clk);
    RUWr = 1'b0; rs1 = 5'd5;
    #2;
    $display("x5 = 0x%h (debe ser 0x0000FFFF)", RU_rs1);

    $display("\n--- Prueba 6: Lectura asíncrona de múltiples registros ---");
    rs1 = 5'd10; rs2 = 5'd5;
    #2;
    $display("Lectura simultánea: x10=0x%h, x5=0x%h", RU_rs1, RU_rs2);

    $display("\n=================================================================");
    $display("                     FIN DE SIMULACIÓN");
    $display("=================================================================");
    #20 $finish;
  end
endmodule
