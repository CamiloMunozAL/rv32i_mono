// ============================================================================
// Debouncer Module
// ============================================================================
// Módulo anti-rebote para botones de la FPGA
// Elimina ruido y rebotes mecánicos de los botones
// ============================================================================

module debouncer #(
    parameter DEBOUNCE_TIME = 20'd1_000_000  // ~20ms a 50MHz
)(
    input  logic clk,
    input  logic rst,
    input  logic button_in,
    output logic button_out
);

    logic [19:0] counter;
    logic button_sync_0, button_sync_1;

    // Sincronizador de dos flip-flops para evitar metaestabilidad
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            button_sync_0 <= 1'b1;  // Botones activos en bajo en DE1-SoC
            button_sync_1 <= 1'b1;
        end else begin
            button_sync_0 <= button_in;
            button_sync_1 <= button_sync_0;
        end
    end

    // Lógica de debounce
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 20'd0;
            button_out <= 1'b1;
        end else begin
            if (button_sync_1 == button_out) begin
                // Estado estable
                counter <= 20'd0;
            end else begin
                // Estado inestable
                counter <= counter + 20'd1;
                if (counter >= DEBOUNCE_TIME) begin
                    button_out <= button_sync_1;
                    counter <= 20'd0;
                end
            end
        end
    end

endmodule
