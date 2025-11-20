//Program Counter (PC)

module pc(
  input logic clk, // Reloj del sistema
  input logic reset, // Señal de reinicio (activo alto)
  input logic [31:0] next_pc, // Dirección de la siguiente instrucción
  output logic [31:0] pc_out // Dirección actual del PC
);

  always_ff @(posedge clk) begin
    if (reset) begin
      pc_out <= 32'b0; // Reiniciar el PC a 0
    end else begin
      pc_out <= next_pc; // Actualizar el PC con la siguiente dirección
    end
  end
endmodule