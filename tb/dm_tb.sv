`timescale 1ns/1ps

module dm_tb;

    logic clk;
    logic DMWr;
    logic [2:0] DMCtrl;
    logic [31:0] addr, DataWr, DataRd;

    // Instancia de la memoria
    dm uut (
        .clk(clk),
        .DMWr(DMWr),
        .DMCtrl(DMCtrl),
        .addr(addr),
        .DataWr(DataWr),
        .DataRd(DataRd)
    );

    // Generador de reloj (10 ns período)
    initial clk = 0;
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        $dumpfile("vcd/dm_tb.vcd");
        $dumpvars(0, dm_tb);
        $display("=== INICIO TESTBENCH DATA MEMORY ===");

        DMWr = 0; addr = 0; DataWr = 0; DMCtrl = 3'b010;
        #10;

        // --- Store Word (SW) ---
        DMWr = 1;
        DMCtrl = 3'b010;  // SW
        addr = 32'h00000004;
        DataWr = 32'hDEADBEEF;
        @(posedge clk);
        #1;  // Esperar después del flanco
        DMWr = 0;

        // --- Load Word (LW) ---
        #10;
        DMCtrl = 3'b010;  // LW
        addr = 32'h00000004;
        #2 $display("LW  -> DataRd = %h (esperado DEADBEEF)", DataRd);

        // --- Store Byte (SB) ---
        #10;
        DMWr = 1;
        DMCtrl = 3'b000;  // SB
        addr = 32'h00000008;
        DataWr = 32'h000000AA;
        @(posedge clk);
        #1;  // Esperar después del flanco
        DMWr = 0;

        // --- Load Byte (LB) ---
        #10;
        DMCtrl = 3'b000;  // LB (signed)
        addr = 32'h00000008;
        #2 $display("LB  -> DataRd = %h (esperado FFFFFFAA)", DataRd);

        // --- Load Byte Unsigned (LBU) ---
        #10;
        DMCtrl = 3'b100;  // LBU (unsigned)
        addr = 32'h00000008;
        #2 $display("LBU -> DataRd = %h (esperado 000000AA)", DataRd);

        // --- Store Halfword (SH) y Load Halfword Unsigned (LHU) ---
        #10;
        DMWr = 1;
        DMCtrl = 3'b001;  // SH
        addr = 32'h0000000C;
        DataWr = 32'h0000BEEF;
        @(posedge clk);
        #1;  // Esperar después del flanco
        DMWr = 0;

        #10;
        DMCtrl = 3'b101;  // LHU
        addr = 32'h0000000C;
        #2 $display("LHU -> DataRd = %h (esperado 0000BEEF)", DataRd);

        #20;
        $display("=== FIN TESTBENCH ===");
        $finish;
    end
endmodule
