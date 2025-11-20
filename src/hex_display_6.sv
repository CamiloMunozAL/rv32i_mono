// ============================================================================
// Hex Display 6 Digits Module
// ============================================================================
// Maneja 6 displays de 7 segmentos para mostrar valores de 24 bits
// Usa el módulo hex_decoder existente para cada dígito
// ============================================================================

module hex_display_6 (
    input  logic [23:0] value,          // Valor de 24 bits a mostrar
    output logic [6:0]  hex0,           // Display 0 (LSB)
    output logic [6:0]  hex1,           // Display 1
    output logic [6:0]  hex2,           // Display 2
    output logic [6:0]  hex3,           // Display 3
    output logic [6:0]  hex4,           // Display 4
    output logic [6:0]  hex5            // Display 5 (MSB)
);

    // Instanciar 6 decodificadores hexadecimales
    hex_decoder decoder0 (.hex_value(value[3:0]),   .seg(hex0));
    hex_decoder decoder1 (.hex_value(value[7:4]),   .seg(hex1));
    hex_decoder decoder2 (.hex_value(value[11:8]),  .seg(hex2));
    hex_decoder decoder3 (.hex_value(value[15:12]), .seg(hex3));
    hex_decoder decoder4 (.hex_value(value[19:16]), .seg(hex4));
    hex_decoder decoder5 (.hex_value(value[23:20]), .seg(hex5));

endmodule
