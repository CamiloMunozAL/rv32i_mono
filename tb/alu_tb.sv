`timescale 1ns/1ps

module alu_tb;

  logic signed [31:0] A, B;
  logic [3:0] ALUOp;
  logic signed [31:0] ALURes;

  alu uut (
    .A(A), .B(B), .ALUOp(ALUOp), .ALURes(ALURes)
  );

  initial begin
    $dumpfile("vcd/alu_tb.vcd");  // Archivo de salida para la forma de onda
    $dumpvars(0, alu_tb);  // Guarda todas las señales

    $display("=== INICIO DE SIMULACIÓN ===");

    // Suma
    A = 32'd10; B = 32'd5; ALUOp = 4'b0000; #10;
    $display("ADD: %d + %d = %d", A, B, ALURes);

    // Resta
    A = 32'd10; B = 32'd20; ALUOp = 4'b1000; #10;
    $display("SUB: %d - %d = %d", A, B, ALURes);

    // Shift lógico izquierda
    A = 32'd3; B = 32'd2; ALUOp = 4'b0001; #10;
    $display("SLL: %d << %d = %d", A, B, ALURes);

    // Menor que (signed)
    A = -5; B = 3; ALUOp = 4'b0010; #10;
    $display("SLT: %d < %d = %d", A, B, ALURes);

    // Menor que (unsigned)
    A = -5; B = 3; ALUOp = 4'b0011; #10;
    $display("SLTU: %d < %d = %d", A, B, ALURes);

    // XOR
    A = 32'hF0F0F0F0; B = 32'h0F0F0F0F; ALUOp = 4'b0100; #10;
    $display("XOR: %h ^ %h = %h", A, B, ALURes);

    // Shift aritmético derecha
    A = -32'd64; B = 32'd3; ALUOp = 4'b1101; #10;
    $display("SRA: %d >>> %d = %d", A, B, ALURes);

    // OR
    A = 32'hAAAA0000; B = 32'h0000BBBB; ALUOp = 4'b0110; #10;
    $display("OR: %h | %h = %h", A, B, ALURes);

    // AND
    A = 32'hFFFF0000; B = 32'h00FF00FF; ALUOp = 4'b0111; #10;
    $display("AND: %h & %h = %h", A, B, ALURes);

    // Pasar B
    A = 32'h12345678; B = 32'h87654321; ALUOp = 4'b1001; #10;
    $display("PASS B: %h", ALURes);

    $display("=== FIN DE SIMULACIÓN ===");
    #10 $finish;
  end

endmodule
