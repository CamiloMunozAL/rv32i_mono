/*
Modulo del generador de inmediatos (immgen) para el conjunto de instrucciones RISC-V.
Este módulo toma una instrucción de 32 bits y genera el inmediato correspondiente
	6. Imm gen
		a. Input: inst[31:7] 25 bits imm, immsrc (3bits)(desde la unidad de control)
		b. Output: immext (32bit)
    I: 000
    S: 001
    B: 101
    U: 010
    J: 011
*/

module immgen(
  input logic [31:0] inst, // Instrucción de 32 bits
  input logic [2:0] immsrc, // Fuente del inmediato (3 bits)

  output logic signed [31:0] immext // Inmediato extendido a 32 bits
);

  wire signed [31:0] imm_I = {{20{inst[31]}}, inst[31:20]};
  wire signed [31:0] imm_S = {{20{inst[31]}}, inst[31:25], inst[11:7]};
  wire signed [31:0] imm_B = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
  wire signed [31:0] imm_U = {inst[31:12], 12'b0};
  wire signed [31:0] imm_J = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};

  always_comb begin
    case (immsrc)
      3'b000: immext = imm_I;
      3'b001: immext = imm_S;
      3'b101: immext = imm_B;
      3'b010: immext = imm_U;
      3'b011: immext = imm_J;
      default: immext = 32'b0;
    endcase
  end
endmodule