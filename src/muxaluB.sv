/*
mux para seleccionar la primera entrada B de la ALU
inputs:
- 32 bits del immgen
- 32 bits de la RU[rs2]
outputs:
- 32 bits de la entrada B seleccionada
control:
- 1 bit para seleccionar entre immgen o RU[rs2] ALUBSrc de la CU
*/

module muxaluB (
    input logic [31:0] immgen,
    input logic [31:0] ru_rs2,
    input logic aluBSrc,
    output logic [31:0] aluB
);

    always_comb begin
        case (aluBSrc)
            1'b0: aluB = ru_rs2; // Selecciona RU[rs2]
            1'b1: aluB = immgen; // Selecciona immgen
            default: aluB = 32'b0; // Valor por defecto (no debería ocurrir)
        endcase
    end
endmodule