// ============================================================================
// Clock Divider Testbench
// ============================================================================

`timescale 1ns/1ps

module clock_divider_tb;

    logic clk_in;
    logic rst;
    logic clk_out;

    // Instancia del DUT
    clock_divider #(
        .DIVIDER(10)  // Dividir por 10 para simulación
    ) dut (
        .clk_in(clk_in),
        .rst(rst),
        .clk_out(clk_out)
    );

    // Generador de clock de entrada (50 MHz = 20ns)
    initial begin
        clk_in = 0;
        forever #10 clk_in = ~clk_in;
    end

    // Estímulos
    initial begin
        $dumpfile("vcd/clock_divider_tb.vcd");
        $dumpvars(0, clock_divider_tb);

        // Reset
        rst = 1;
        #50;
        rst = 0;

        // Dejar correr por varios ciclos
        #2000;

        $display("=== Test completado ===");
        $display("Clock de entrada: 50MHz");
        $display("Clock de salida esperado: 5MHz (DIVIDER=10)");
        $finish;
    end

    // Monitor para verificar la frecuencia
    integer edge_count;
    real start_time, end_time, frequency;

    initial begin
        edge_count = 0;
        start_time = 0;
        @(negedge rst);
        start_time = $realtime;
        
        repeat(10) @(posedge clk_out) begin
            edge_count = edge_count + 1;
        end
        
        end_time = $realtime;
        frequency = edge_count / ((end_time - start_time) / 1e9);
        $display("Frecuencia medida: %f MHz", frequency / 1e6);
    end

endmodule
