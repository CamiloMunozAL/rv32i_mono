module alu(
  input logic signed [31:0] A,// Bus de datos de entrada A de 32 bits
  input logic signed [31:0] B,// Bus de datos de entrada B de 32 bits

  input logic [3:0] ALUOp, // Operación a realizar 4 bits

  output logic signed [31:0] ALURes// Resultado de la alu de 32 bits
);

  always_comb begin
    case (ALUOp)
    4'b0000: ALURes = A + B; // Suma
    4'b1000: ALURes = A - B; // Resta
    4'b0001: ALURes = A << B; // Desplazamiento lógico a la izquierda
    4'b0010: ALURes = A < B; // Menor que (set on less than)
    4'b0011: ALURes = ($unsigned(A) < $unsigned(B)) ? 32'sd1 : 32'sd0; // Menor que sin signo
    4'b0100: ALURes = A ^ B; // XOR
    4'b0101: ALURes = A >> B; // Desplazamiento lógico a la derecha
    4'b1101: ALURes = A >>> B; // Desplazamiento aritmético a la derecha
    4'b0110: ALURes = A | B; // OR
    4'b0111: ALURes = A & B; // AND
    4'b1001: ALURes = B; // Pass B (para instrucciones como LUI)

    endcase
  end

endmodule