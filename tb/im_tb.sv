`timescale 1ns / 1ps

/*
Testbench para Instruction Memory (im)
Verifica:
- Lectura correcta de instrucciones en diferentes direcciones
- Acceso por palabra (addr dividido entre 4)
- Programa almacenado correctamente
*/

module im_tb;

    // Señales del testbench
    logic [31:0] addr;
    logic [31:0] inst;

    // Instancia del módulo
    im uut (
        .addr(addr),
        .inst(inst)
    );

    // Proceso de prueba
    initial begin
        $display("=== Testbench: Instruction Memory ===\n");

        // --- Prueba 1: Primera instrucción (ADDI x1, x0, 1) ---
        addr = 32'h00000000;
        #10;
        $display("Prueba 1 - addr=0x%08h: inst=0x%08h (esperado: 0x00100093 - ADDI x1,x0,1)", addr, inst);
        
        // --- Prueba 2: Segunda instrucción (ADDI x2, x0, 6) ---
        addr = 32'h00000004; // mem[1]
        #10;
        $display("Prueba 2 - addr=0x%08h: inst=0x%08h (esperado: 0x00600113 - ADDI x2,x0,6)", addr, inst);
        
        // --- Prueba 3: Inicio del loop (ADD x3, x3, x1) ---
        addr = 32'h00000010; // mem[4]
        #10;
        $display("Prueba 3 - addr=0x%08h: inst=0x%08h (esperado: 0x001181B3 - ADD x3,x3,x1)", addr, inst);
        
        // --- Prueba 4: BLT corregido ---
        addr = 32'h00000018; // mem[6]
        #10;
        $display("Prueba 4 - addr=0x%08h: inst=0x%08h (esperado: 0xFE20CCE3 - BLT x1,x2,-8)", addr, inst);
        
        // --- Prueba 5: Store result (SW x3, 0(x4)) ---
        addr = 32'h0000001C; // mem[7]
        #10;
        $display("Prueba 5 - addr=0x%08h: inst=0x%08h (esperado: 0x00322023 - SW x3,0(x4))", addr, inst);
        
        // --- Prueba 6: JAL instruction ---
        addr = 32'h00000094; // mem[37] = 0x94/4 = 37
        #10;
        $display("Prueba 6 - addr=0x%08h: inst=0x%08h (esperado: 0x008000EF - JAL x1,+8)", addr, inst);
        
        // --- Prueba 7: DEADBEEF (debe saltar sobre esta) ---
        addr = 32'h00000098; // mem[38]
        #10;
        $display("Prueba 7 - addr=0x%08h: inst=0x%08h (esperado: 0xDEADBEEF - dato invalido)", addr, inst);
        
        // --- Prueba 8: Después del salto ---
        addr = 32'h0000009C; // mem[39]
        #10;
        $display("Prueba 8 - addr=0x%08h: inst=0x%08h (esperado: 0x01400293 - ADDI x5,x0,20)", addr, inst);
        
        // --- Prueba 9: NOPs al final ---
        addr = 32'h000000A0; // mem[40]
        #10;
        $display("Prueba 9 - addr=0x%08h: inst=0x%08h (esperado: 0x00000013 - NOP)", addr, inst);
        
        // --- Prueba 10: Verificar que addr se divide entre 4 correctamente ---
        addr = 32'h00000002; // No alineado, pero debe leer mem[0]
        #10;
        $display("\nPrueba 10 - addr=0x%08h (no alineado): inst=0x%08h (debe leer mem[0])", addr, inst);
        
        addr = 32'h00000006; // No alineado, debe leer mem[1]
        #10;
        $display("Prueba 10b - addr=0x%08h (no alineado): inst=0x%08h (debe leer mem[1])", addr, inst);

        $display("\n=== Testbench completado ===");
        $finish;
    end

    // Generar archivo VCD para WaveTrace
    initial begin
        $dumpfile("vcd/im_tb.vcd");
        $dumpvars(0, im_tb);
    end

endmodule
