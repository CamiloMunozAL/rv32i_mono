/*
Modulo de la unidad branch (BRU)
inputs:
- ru[rs1] de 32 bits desde la unidad de registros
- ru[rs2] de 32 bits desde la unidad de registros
outputs:
- 1 bit de señal de branch (BrTaken) hacia mux para el program counter
control:
- 5 bits para seleccionar el tipo de branch (BrOp) desde la unidad de control

NextPCSrc -> BrOp
0 -> 00XXX
= -> 01000
!= -> 01001
< -> 01100
>= -> 01101
<u -> 01110
>=u -> 01111
1 -> 1XXXX

*/
module bru (
    input logic [31:0] ru_rs1,
    input logic [31:0] ru_rs2,
    input logic [4:0] brOp,
    output logic NextPCSrc
);

  always_comb begin
    case (brOp)
      5'b00000, 5'b10000: NextPCSrc = 1'b0; // No branch
      5'b01000: NextPCSrc = (ru_rs1 == ru_rs2) ? 1'b1 : 1'b0; // BEQ
      5'b01001: NextPCSrc = (ru_rs1 != ru_rs2) ? 1'b1 : 1'b0; // BNE
      5'b01100: NextPCSrc = ($signed(ru_rs1) < $signed(ru_rs2)) ? 1'b1 : 1'b0; // BLT
      5'b01101: NextPCSrc = ($signed(ru_rs1) >= $signed(ru_rs2)) ? 1'b1 : 1'b0; // BGE
      5'b01110: NextPCSrc = (ru_rs1 < ru_rs2) ? 1'b1 : 1'b0; // BLTU
      5'b01111: NextPCSrc = (ru_rs1 >= ru_rs2) ? 1'b1 : 1'b0; // BGEU
      default: NextPCSrc = 1'b0; // Valor por defecto (no debería ocurrir)
    endcase
  end
endmodule