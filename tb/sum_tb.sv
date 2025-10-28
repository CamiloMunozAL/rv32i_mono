//Testbench sumador 4 al program counter (PC)

`timescale 1ns/1ps

module sum_tb;
  logic [31:0] pc_in;
  logic [31:0] pc_out;
  // Instancia del módulo sum
  sum uut (
    .pc_in(pc_in),
    .pc_out(pc_out)
  );
  initial begin
    $dumpfile("sum.vcd");
    $dumpvars(0, sum_tb);
    $display("=== INICIO DE SIMULACIÓN ===");

    // Prueba 1: pc_in = 0x00000000
    pc_in = 32'h00000000;
    #10;
    $display("pc_in: %h, pc_out (debe ser 0x00000004): %h", pc_in, pc_out);

    // Prueba 2: pc_in = 0x00000004
    pc_in = 32'h00000004;
    #10;
    $display("pc_in: %h, pc_out (debe ser 0x00000008): %h", pc_in, pc_out);

    // Prueba 3: pc_in = 0x0000000C
    pc_in = 32'h0000000C;
    #10;
    $display("pc_in: %h, pc_out (debe ser 0x00000010): %h", pc_in, pc_out);

    // Prueba 4: pc_in = 0xFFFFFFFC
    pc_in = 32'hFFFFFFFC;
    #10;
    $display("pc_in: %h, pc_out (debe ser 0x00000000): %h", pc_in, pc_out);

    $display("=== FIN DE SIMULACIÓN ===");
    #10 $finish;
  end
endmodule
