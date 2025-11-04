/* testbench para el mux para seleccionar la primera entrada B de la ALU
mux para seleccionar la primera entrada B de la ALU
inputs:
- 32 bits del immgen
- 32 bits de la RU[rs2]
outputs:
- 32 bits de la entrada B seleccionada
control:
- 1 bit para seleccionar entre immgen o RU[rs2] ALUBSrc de la CU
*/

`timescale 1ps/1ps

module muxaluB_tb;

    // Entradas
    logic [31:0] immgen;
    logic [31:0] ru_rs2;
    logic aluBSrc;

    // Salida
    logic [31:0] aluB;

    // Instanciar el módulo bajo prueba
    muxaluB dut (
        .immgen(immgen),
        .ru_rs2(ru_rs2),
        .aluBSrc(aluBSrc),
        .aluB(aluB)
    );

    // Generar estímulos
    initial begin
      $dumpfile("vcd/muxaluB_tb.vcd");
      $dumpvars(0, muxaluB_tb);
      $display("=== INICIO DE SIMULACIÓN DEL TESTBENCH DEL MUXALUB ===");
        // Caso 1: Seleccionar RU[rs2]
        immgen = 32'h00000001;
        ru_rs2 = 32'h00000002;
        aluBSrc = 1'b0;
        #10;
        if(aluB == ru_rs2) $display("Correcto en caso 1");
        else $display("Error en caso 1");

        // Caso 2: Seleccionar immgen
        immgen = 32'h00000003;
        ru_rs2 = 32'h00000004;
        aluBSrc = 1'b1;
        #10;
        if(aluB == immgen) $display("Correcto en caso 2");
        else $display("Error en caso 2");

        $finish;
    end
endmodule