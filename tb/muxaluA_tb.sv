/*
testbench para el mux para seleccionar la primera entrada A de la ALU
inputs:
- 32 bits del Program Counter
- 32 bits de la RU[rs1]
outputs:
- 32 bits de la entrada A seleccionada
control:
- 1 bit para seleccionar entre PC o RU[rs1] ALUASrc de la CU
*/
`timescale 1ps/1ps

module muxaluA_tb;

    // Entradas
    logic [31:0] pc;
    logic [31:0] ru_rs1;
    logic aluASrc;

    // Salida
    logic [31:0] aluA;

    // Instanciar el módulo bajo prueba
    muxaluA dut (
        .pc(pc),
        .ru_rs1(ru_rs1),
        .aluASrc(aluASrc),
        .aluA(aluA)
    );

    // Generar estímulos
    initial begin
      $dumpfile("vcd/muxaluA_tb.vcd");
      $dumpvars(0, muxaluA_tb);
      $display("=== INICIO DE SIMULACIÓN DEL TESTBENCH DEL MUXALUA ===");
        // Caso 1: Seleccionar RU[rs1]
        pc = 32'h00000001;
        ru_rs1 = 32'h00000002;
        aluASrc = 1'b0;
        #10;
        if(aluA == ru_rs1) $display("Correcto en caso 1");
        else $display("Error en caso 1");

        // Caso 2: Seleccionar PC
        pc = 32'h00000003;
        ru_rs1 = 32'h00000004;
        aluASrc = 1'b1;
        #10;
        if(aluA == pc) $display("Correcto en caso 2");
        else $display("Error en caso 2");

        $finish;
    end

endmodule