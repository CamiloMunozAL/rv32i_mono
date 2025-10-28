//Program counter testbench

`timescale 1ns/1ps

module pc_tb;

  logic clk;
  logic reset;
  logic [31:0] next_pc;
  logic [31:0] pc_out;

  // Instancia del módulo PC
  pc uut (
    .clk(clk),
    .reset(reset),
    .next_pc(next_pc),
    .pc_out(pc_out)
  );

  // Generador de reloj: periodo 10 ns (100 MHz)
  always #5 clk = ~clk;

  initial begin
    // Inicialización
    $dumpfile("pc.vcd");
    $dumpvars(0, pc_tb);
    $display("=== INICIO DE SIMULACIÓN ===");

    clk = 0;
    reset = 1;     // Activa reset
    next_pc = 32'h00000000;

    #10;           // Espera un ciclo
    reset = 0;     // Desactiva reset

    // Prueba 1: cargar 0x00000004
    next_pc = 32'h00000004;
    #10;
    $display("PC debe ser 0x00000004: %h", pc_out);

    // Prueba 2: cargar 0x00000008
    next_pc = 32'h00000008;
    #10;
    $display("PC debe ser 0x00000008: %h", pc_out);

    // Prueba 3: cargar 0x0000000C
    next_pc = 32'h0000000C;
    #10;
    $display("PC debe ser 0x0000000C: %h", pc_out);

    // Prueba 4: aplicar reset
    reset = 1;
    #10;
    $display("Después de reset, PC debe ser 0: %h", pc_out);
    reset = 0;

    // Prueba 5: cargar nuevo valor después de reset
    next_pc = 32'h00000020;
    #10;
    $display("PC debe ser 0x00000020: %h", pc_out);

    $display("=== FIN DE SIMULACIÓN ===");
    #10 $finish;
  end

endmodule
