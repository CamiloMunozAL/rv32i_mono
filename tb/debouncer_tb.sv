// ============================================================================
// Debouncer Testbench
// ============================================================================

`timescale 1ns/1ps

module debouncer_tb;

    logic clk;
    logic rst;
    logic button_in;
    logic button_out;

    // Instancia del DUT
    debouncer #(
        .DEBOUNCE_TIME(100)  // Valor pequeño para simulación rápida
    ) dut (
        .clk(clk),
        .rst(rst),
        .button_in(button_in),
        .button_out(button_out)
    );

    // Generador de clock (50 MHz = 20ns periodo)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Estímulos
    initial begin
        $dumpfile("vcd/debouncer_tb.vcd");
        $dumpvars(0, debouncer_tb);

        // Inicialización
        rst = 1;
        button_in = 1;  // Botón no presionado (activo bajo)
        #50;
        rst = 0;
        #100;

        $display("=== Test 1: Botón presionado sin rebotes ===");
        button_in = 0;  // Presionar botón
        #3000;
        button_in = 1;  // Soltar botón
        #3000;

        $display("=== Test 2: Botón con rebotes ===");
        // Simular rebotes al presionar
        button_in = 0;
        #40;
        button_in = 1;
        #20;
        button_in = 0;
        #30;
        button_in = 1;
        #15;
        button_in = 0;  // Finalmente estable
        #3000;

        // Simular rebotes al soltar
        button_in = 1;
        #40;
        button_in = 0;
        #20;
        button_in = 1;
        #30;
        button_in = 0;
        #15;
        button_in = 1;  // Finalmente estable
        #3000;

        $display("=== Test 3: Pulsos muy cortos (ignorados) ===");
        button_in = 0;
        #30;  // Muy corto, debería ser ignorado
        button_in = 1;
        #3000;

        $display("=== Simulación completada ===");
        $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t rst=%b button_in=%b button_out=%b", 
                 $time, rst, button_in, button_out);
    end

endmodule
