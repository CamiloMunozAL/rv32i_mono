/* 
Testbench
Modulo para el mux para el datawr para el register unit (RU)
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

`timescale 1ns / 1ps
module muxrudata_tb;

    // Señales internas
    logic [31:0] PCInc;
    logic [31:0] ALURes;
    logic [31:0] DataRd;
    logic [1:0]  RUDataWrSrc;
    logic [31:0] DataWr;

    // Instancia del módulo muxrudata
    muxrudata uut (
        .PCInc(PCInc),
        .ALURes(ALURes),
        .DataRd(DataRd),
        .RUDataWrSrc(RUDataWrSrc),
        .DataWr(DataWr)
    );

    // Test sequence
    initial begin
        $dumpfile("vcd/muxrudata_tb.vcd");
        $dumpvars(0, muxrudata_tb);
        $display("=== INICIO TESTBENCH MUXRUData ===");

        // Test case 1: Select ALURes
        PCInc = 32'h00000010;
        ALURes = 32'hDEADBEEF;
        DataRd = 32'hCAFEBABE;
        RUDataWrSrc = 2'b00; // Select ALURes
        #10;
        $display("Test 1 - RUDataWrSrc=00: DataWr = %h (esperado DEADBEEF)", DataWr);

        // Test case 2: Select DataRd
        RUDataWrSrc = 2'b01; // Select DataRd
        #10;
        $display("Test 2 - RUDataWrSrc=01: DataWr = %h (esperado CAFEBABE)", DataWr);

        // Test case 3: Select PCInc
        RUDataWrSrc = 2'b10; // Select PCInc
        #10;
        $display("Test 3 - RUDataWrSrc=10: DataWr = %h (esperado 00000010)", DataWr);

        $display("=== FIN TESTBENCH MUXRUData ===");
        $finish;
    end
endmodule
