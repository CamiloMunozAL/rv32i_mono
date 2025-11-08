/* Modulo para el mux para el datawr para el register unit (RU)
	13. Mux: RUDataWrSrc
		a. PCInc(PC+4), ALURes, DataRd
		b. Output: DataWr
Funcion: Selecciona que valor se escribe de vuelta en el registro rd
inputs:
- 32 bits de PC+4 (10)
- 32 bits de Datard (01) de la data memory (dm)
- 32 bits de alu (00)
outputs:
- 32 bits de DataWr para la unidad de registros (ru)
control:
- 2 bits para RUDataWrSrc
*/

module muxrudata (
    input  logic [31:0] PCInc,       // PC + 4
    input  logic [31:0] ALURes,      // Resultado de la ALU
    input  logic [31:0] DataRd,      // Dato leído de la memoria
    input  logic [1:0]  RUDataWrSrc, // Control del mux
    output logic [31:0] DataWr       // Dato a escribir en el registro
);

    // Mux para seleccionar el dato a escribir en el registro
    always_comb begin
        case (RUDataWrSrc)
            2'b00: DataWr = ALURes;   // Desde la ALU
            2'b01: DataWr = DataRd;   // Desde la memoria de datos
            2'b10: DataWr = PCInc;    // Desde PC + 4
            default: DataWr = 32'b0;   // Valor por defecto (seguridad)
        endcase
    end
endmodule
