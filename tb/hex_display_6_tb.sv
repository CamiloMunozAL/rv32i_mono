// ============================================================================
// Hex Display 6 Digits Testbench
// ============================================================================

`timescale 1ns/1ps

module hex_display_6_tb;

    logic [23:0] value;
    logic [6:0] hex0, hex1, hex2, hex3, hex4, hex5;

    // Instancia del DUT
    hex_display_6 dut (
        .value(value),
        .hex0(hex0),
        .hex1(hex1),
        .hex2(hex2),
        .hex3(hex3),
        .hex4(hex4),
        .hex5(hex5)
    );

    // Estímulos
    initial begin
        $dumpfile("vcd/hex_display_6_tb.vcd");
        $dumpvars(0, hex_display_6_tb);

        $display("=== Test de Hex Display 6 Dígitos ===");
        
        // Test 1: Valor 0
        value = 24'h000000;
        #100;
        $display("Valor: %h => HEX5-0: %h %h %h %h %h %h", 
                 value, hex5, hex4, hex3, hex2, hex1, hex0);

        // Test 2: Valor máximo
        value = 24'hFFFFFF;
        #100;
        $display("Valor: %h => HEX5-0: %h %h %h %h %h %h", 
                 value, hex5, hex4, hex3, hex2, hex1, hex0);

        // Test 3: Valores aleatorios
        value = 24'h123456;
        #100;
        $display("Valor: %h => HEX5-0: %h %h %h %h %h %h", 
                 value, hex5, hex4, hex3, hex2, hex1, hex0);

        value = 24'hABCDEF;
        #100;
        $display("Valor: %h => HEX5-0: %h %h %h %h %h %h", 
                 value, hex5, hex4, hex3, hex2, hex1, hex0);

        value = 24'hDEADBE;
        #100;
        $display("Valor: %h => HEX5-0: %h %h %h %h %h %h", 
                 value, hex5, hex4, hex3, hex2, hex1, hex0);

        // Test 4: Conteo incremental
        $display("=== Conteo incremental ===");
        for (int i = 0; i < 16; i++) begin
            value = i;
            #50;
            $display("Valor: %h", value);
        end

        $display("=== Simulación completada ===");
        $finish;
    end

endmodule
