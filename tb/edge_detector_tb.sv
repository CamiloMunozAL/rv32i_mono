// ============================================================================
// Edge Detector Testbench
// ============================================================================

`timescale 1ns/1ps

module edge_detector_tb;

    logic clk;
    logic rst;
    logic signal_in;
    logic edge_detected;

    // Instancia del DUT
    edge_detector dut (
        .clk(clk),
        .rst(rst),
        .signal_in(signal_in),
        .edge_detected(edge_detected)
    );

    // Generador de clock
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Estímulos
    initial begin
        $dumpfile("vcd/edge_detector_tb.vcd");
        $dumpvars(0, edge_detector_tb);

        // Inicialización
        rst = 1;
        signal_in = 1;
        #50;
        rst = 0;
        #100;

        $display("=== Test 1: Flanco descendente ===");
        signal_in = 0;  // Flanco descendente
        #20;
        signal_in = 1;
        #100;

        $display("=== Test 2: Múltiples flancos ===");
        signal_in = 0;
        #40;
        signal_in = 1;
        #40;
        signal_in = 0;
        #40;
        signal_in = 1;
        #100;

        $display("=== Test 3: Señal mantenida en bajo ===");
        signal_in = 0;
        #200;  // Debe detectar solo un pulso al inicio
        signal_in = 1;
        #100;

        $display("=== Simulación completada ===");
        $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t rst=%b signal_in=%b edge_detected=%b", 
                 $time, rst, signal_in, edge_detected);
    end

endmodule
