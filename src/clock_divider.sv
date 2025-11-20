// ============================================================================
// Clock Divider Module
// ============================================================================
// Divide el clock de 50MHz para generar clocks más lentos
// Usado para el modo automático de ejecución
// ============================================================================

module clock_divider #(
    parameter DIVIDER = 25_000_000  // Default: 1Hz desde 50MHz
)(
    input  logic clk_in,
    input  logic rst,
    output logic clk_out
);

    logic [31:0] counter;

    always_ff @(posedge clk_in or posedge rst) begin
        if (rst) begin
            counter <= 32'd0;
            clk_out <= 1'b0;
        end else begin
            if (counter >= DIVIDER - 1) begin
                counter <= 32'd0;
                clk_out <= ~clk_out;
            end else begin
                counter <= counter + 32'd1;
            end
        end
    end

endmodule
