/*
Testbench para el procesador RISC-V RV32I monociclo

Este testbench:
1. Instancia el módulo monociclo
2. Genera señales de reloj y reset
3. Monitorea las señales principales
4. Genera archivo VCD para visualización
*/

`timescale 1ns/1ps

module monociclo_tb;

    //========================================================
    // SEÑALES DEL TESTBENCH
    //========================================================
    logic        clk;
    logic        reset;
    
    // Señales de debug
    logic [31:0] pc_out;
    logic [31:0] inst_out;
    logic [31:0] alu_result_out;
    logic [31:0] alu_a_out;
    logic [31:0] alu_b_out;
    logic [31:0] next_pc_out;
    logic [31:0] debug_x1, debug_x2, debug_x3, debug_x4, debug_x5, debug_x6, debug_x7;
    logic [31:0] debug_dm_word [0:7];
    
    //========================================================
    // INSTANCIACIÓN DEL DUT (Device Under Test)
    //========================================================
    monociclo u_monociclo (
        .clk(clk),
        .reset(reset),
        .pc_out(pc_out),
        .inst_out(inst_out),
        .alu_result_out(alu_result_out),
        .alu_a_out(alu_a_out),
        .alu_b_out(alu_b_out),
        .next_pc_out(next_pc_out),
        .debug_x1(debug_x1),
        .debug_x2(debug_x2),
        .debug_x3(debug_x3),
        .debug_x4(debug_x4),
        .debug_x5(debug_x5),
        .debug_x6(debug_x6),
        .debug_x7(debug_x7),
        .debug_dm_word(debug_dm_word)
    );
    
    //========================================================
    // GENERACIÓN DE RELOJ
    //========================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Período de 10ns (100 MHz)
    end
    
    //========================================================
    // SECUENCIA DE RESET Y PRUEBA
    //========================================================
    initial begin
        // Archivo VCD para visualización
        $dumpfile("vcd/monociclo_tb.vcd");
        $dumpvars(0, monociclo_tb);
        
        // Inicialización
        reset = 1;
        
        // Aplicar reset
        #20;
        reset = 0;
        
        // Ejecutar instrucciones (tenemos ~43 instrucciones + loop iterations)
        // Cada instrucción toma 1 ciclo = 10ns
        // Loop puede ejecutar varias veces, dar suficiente tiempo
        #800;
        
        // Mostrar resultados
        $display("\n========================================");
        $display("RESULTADOS DE LA SIMULACIÓN");
        $display("========================================\n");
        
        $display("Valor final del PC: 0x%h", pc_out);
        $display("\nEstado del banco de registros:");
        $display("x0  (zero) = 0x%h", u_monociclo.u_ru.RU[0]);
        $display("x1  (ra)   = 0x%h", u_monociclo.u_ru.RU[1]);
        $display("x2  (sp)   = 0x%h", u_monociclo.u_ru.RU[2]);
        $display("x3  (gp)   = 0x%h", u_monociclo.u_ru.RU[3]);
        $display("x4  (tp)   = 0x%h", u_monociclo.u_ru.RU[4]);
        $display("x5  (t0)   = 0x%h", u_monociclo.u_ru.RU[5]);
        $display("x6  (t1)   = 0x%h", u_monociclo.u_ru.RU[6]);
        $display("x7  (t2)   = 0x%h", u_monociclo.u_ru.RU[7]);
        $display("x8  (s0)   = 0x%h", u_monociclo.u_ru.RU[8]);
        $display("x9  (s1)   = 0x%h", u_monociclo.u_ru.RU[9]);
        $display("x10 (a0)   = 0x%h", u_monociclo.u_ru.RU[10]);
        $display("x11 (a1)   = 0x%h", u_monociclo.u_ru.RU[11]);
        $display("x12 (a2)   = 0x%h", u_monociclo.u_ru.RU[12]);
        $display("x13 (a3)   = 0x%h", u_monociclo.u_ru.RU[13]);
        $display("x14 (a4)   = 0x%h", u_monociclo.u_ru.RU[14]);
        $display("x15 (a5)   = 0x%h", u_monociclo.u_ru.RU[15]);
        
        $display("\nPrimeros 8 words de memoria de datos:");
        $display("DM[0] = 0x%h", {u_monociclo.u_dm.mem[3], u_monociclo.u_dm.mem[2], u_monociclo.u_dm.mem[1], u_monociclo.u_dm.mem[0]});
        $display("DM[1] = 0x%h", {u_monociclo.u_dm.mem[7], u_monociclo.u_dm.mem[6], u_monociclo.u_dm.mem[5], u_monociclo.u_dm.mem[4]});
        $display("DM[2] = 0x%h", {u_monociclo.u_dm.mem[11], u_monociclo.u_dm.mem[10], u_monociclo.u_dm.mem[9], u_monociclo.u_dm.mem[8]});
        $display("DM[3] = 0x%h", {u_monociclo.u_dm.mem[15], u_monociclo.u_dm.mem[14], u_monociclo.u_dm.mem[13], u_monociclo.u_dm.mem[12]});
        $display("DM[4] = 0x%h", {u_monociclo.u_dm.mem[19], u_monociclo.u_dm.mem[18], u_monociclo.u_dm.mem[17], u_monociclo.u_dm.mem[16]});
        $display("DM[5] = 0x%h", {u_monociclo.u_dm.mem[23], u_monociclo.u_dm.mem[22], u_monociclo.u_dm.mem[21], u_monociclo.u_dm.mem[20]});
        $display("DM[6] = 0x%h", {u_monociclo.u_dm.mem[27], u_monociclo.u_dm.mem[26], u_monociclo.u_dm.mem[25], u_monociclo.u_dm.mem[24]});
        $display("DM[7] = 0x%h", {u_monociclo.u_dm.mem[31], u_monociclo.u_dm.mem[30], u_monociclo.u_dm.mem[29], u_monociclo.u_dm.mem[28]});
        
        $display("\n========================================\n");
        
        $finish;
    end
    
    //========================================================
    // MONITOR DE EJECUCIÓN
    //========================================================
    always @(posedge clk) begin
        if (!reset) begin
            $display("Ciclo %0t: PC=0x%h, INST=0x%h, ALU_RES=0x%h, RUWr=%b, rd=%d, rs1=%d(0x%h), rs2=%d(0x%h), BrOp=%b, nextPCSrc=%b, NextPC=0x%h", 
                     $time, pc_out, inst_out, alu_result_out,
                     u_monociclo.RUWr, u_monociclo.rd,
                     u_monociclo.rs1, u_monociclo.ru_rs1_data,
                     u_monociclo.rs2, u_monociclo.ru_rs2_data,
                     u_monociclo.BrOp, u_monociclo.nextPCSrc, next_pc_out);
        end
    end

endmodule
