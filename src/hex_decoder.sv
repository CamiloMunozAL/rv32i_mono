/*
Decodificador Hexadecimal para Display de 7 Segmentos
Convierte un valor de 4 bits (0-F) a señales para display de 7 segmentos (ánodo común)
Los displays de la DE1-SoC son de ánodo común, por lo que 0 = encendido, 1 = apagado
*/

module hex_decoder(
  input logic [3:0] hex_value,      // Valor hexadecimal de entrada (0-F)
  output logic [6:0] seg            // Salida para segmentos (activo en bajo)
);

  // Decodificación de cada dígito hexadecimal
  // Segmentos:  seg[6:0] = {g, f, e, d, c, b, a}
  //             
  //       a
  //      ---
  //   f |   | b
  //      -g-
  //   e |   | c
  //      ---
  //       d
  
  always_comb begin
    case (hex_value)
      4'h0: seg = 7'b1000000; // 0
      4'h1: seg = 7'b1111001; // 1
      4'h2: seg = 7'b0100100; // 2
      4'h3: seg = 7'b0110000; // 3
      4'h4: seg = 7'b0011001; // 4
      4'h5: seg = 7'b0010010; // 5
      4'h6: seg = 7'b0000010; // 6
      4'h7: seg = 7'b1111000; // 7
      4'h8: seg = 7'b0000000; // 8
      4'h9: seg = 7'b0010000; // 9
      4'hA: seg = 7'b0001000; // A
      4'hB: seg = 7'b0000011; // b
      4'hC: seg = 7'b1000110; // C
      4'hD: seg = 7'b0100001; // d
      4'hE: seg = 7'b0000110; // E
      4'hF: seg = 7'b0001110; // F
      default: seg = 7'b1111111; // Apagado
    endcase
  end

endmodule
