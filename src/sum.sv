//Sumador de 4 al program counter (PC)

module sum(
  input logic [31:0] pc_in, // Dirección actual del PC
  output logic [31:0] pc_out // Dirección del PC + 4
);

  always_comb begin
    pc_out = pc_in + 4;
  end

endmodule