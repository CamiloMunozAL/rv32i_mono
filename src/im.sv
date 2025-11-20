/*
Modulo para la instruction memory (im)
inputs:
- 32 bits de la dirección (addr) desde el Program Counter
outputs:
- 32 bits de la instrucción (inst)

Funcion: Contiene las instrucciones del programa
*/

module im (
    input  logic [31:0] addr,      // dirección desde el PC
    output logic [31:0] inst       // instrucción de 32 bits
);

    // Memoria de instrucciones - 256 palabras (1KB) - adecuado para FPGA
    (* ramstyle = "M10K" *) logic [31:0] mem [0:255];

    // Programa didáctico RV32I - Demostración completa de arquitectura
    initial begin
        integer i;
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] = 32'h00000013; // NOP (ADDI x0, x0, 0)
        end
        
        // ===================================================================
        // PROGRAMA DIDÁCTICO: Calculadora de suma de números 1 al 5
        // ===================================================================
        // Registros usados:
        // x1 = contador (1, 2, 3, 4, 5)
        // x2 = límite (5)
        // x3 = acumulador de suma
        // x4 = dirección base de memoria
        // x5, x6, x7 = operaciones auxiliares
        // ===================================================================
        
        // --- INICIALIZACIÓN ---
        mem[0]  = 32'h00100093; // ADDI x1, x0, 1       | x1 = 1 (contador)
        mem[1]  = 32'h00600113; // ADDI x2, x0, 6       | x2 = 6 (límite, para loop hasta x1=5)
        mem[2]  = 32'h00000193; // ADDI x3, x0, 0       | x3 = 0 (suma)
        mem[3]  = 32'h00000213; // ADDI x4, x0, 0       | x4 = 0 (dir mem)
        
        // --- LOOP: Sumar números del 1 al 5 ---
        // [mem[4]] INICIO_LOOP:
        mem[4]  = 32'h001181B3; // ADD  x3, x3, x1      | suma += contador
        mem[5]  = 32'h00108093; // ADDI x1, x1, 1       | contador++ (CORREGIDO: rs1=x1, no x0)
        
        // --- Comparar si contador <= límite ---
        mem[6]  = 32'hFE20CCE3; // BLT  x1, x2, -8      | si x1<x2 salta a mem[4] (CORREGIDO: opcode 0x63)
        
        // --- GUARDAR resultado en memoria ---
        mem[7]  = 32'h00322023; // SW   x3, 0(x4)       | mem[0] = suma (debe ser 15)
        
        // --- OPERACIONES ARITMÉTICAS (demostración) ---
        mem[8]  = 32'h00A00293; // ADDI x5, x0, 10      | x5 = 10 = 0x0A
        mem[9]  = 32'h01400313; // ADDI x6, x0, 20      | x6 = 20 = 0x14
        mem[10] = 32'h006283B3; // ADD  x7, x5, x6      | x7 = 30 = 0x1E
        mem[11] = 32'h40628333; // SUB  x6, x5, x6      | x6 = -10 = 0xFFFFFFF6
        
        // --- OPERACIONES LÓGICAS ---
        mem[12] = 32'h0FF00293; // ADDI x5, x0, 255     | x5 = 0xFF
        mem[13] = 32'h0F000313; // ADDI x6, x0, 240     | x6 = 0xF0
        mem[14] = 32'h0062F3B3; // AND  x7, x5, x6      | x7 = 0xF0 operacion AND porque 0xFF & 0xF0 = 0xF0
        mem[15] = 32'h0062E3B3; // OR   x7, x5, x6      | x7 = 0xFF operacion OR porque 0xFF | 0xF0 = 0xFF
        mem[16] = 32'h0062C3B3; // XOR  x7, x5, x6      | x7 = 0x0F operacion XOR porque 0xFF ^ 0xF0 = 0x0F
        
        // --- DESPLAZAMIENTOS ---
        mem[17] = 32'h00800293; // ADDI x5, x0, 8       | x5 = 8
        mem[18] = 32'h00229293; // SLLI x5, x5, 2       | x5 = 32 (<<2) = 0x20
        mem[19] = 32'h0022D293; // SRLI x5, x5, 2       | x5 = 8  (>>2) = 0x08
        mem[20] = 32'hFF000313; // ADDI x6, x0, -16     | x6 = -16 = 0xFFFFFFF0
        mem[21] = 32'h40235313; // SRAI x6, x6, 2       | x6 = -4 (>>2 aritmético) = 0xFFFFFFFC
        
        // --- LOAD/STORE múltiple (usando mem[2]-mem[3] visibles en displays) ---
        mem[22] = 32'h00800213; // ADDI x4, x0, 8       | x4 = 8 (dirección mem[2])
        mem[23] = 32'h02A00293; // ADDI x5, x0, 42      | x5 = 42 = 0x2A
        mem[24] = 32'h00522023; // SW   x5, 0(x4)       | mem[2] = 42 = 0x2A
        mem[25] = 32'h00C00213; // ADDI x4, x0, 12      | x4 = 12 (dirección mem[3])
        mem[26] = 32'h05500293; // ADDI x5, x0, 85      | x5 = 85 = 0x55
        mem[27] = 32'h00522023; // SW   x5, 0(x4)       | mem[3] = 85 = 0x55
        mem[28] = 32'h00800213; // ADDI x4, x0, 8       | x4 = 8 (leer mem[2])
        mem[29] = 32'h00022303; // LW   x6, 0(x4)       | x6 = mem[2] = 42 = 0x2A
        mem[30] = 32'h00C00213; // ADDI x4, x0, 12      | x4 = 12 (leer mem[3])
        mem[31] = 32'h00022383; // LW   x7, 0(x4)       | x7 = mem[3] = 85 = 0x55
        
        // --- SALTOS CONDICIONALES ---
        mem[32] = 32'h00600293; // ADDI x5, x0, 6       | x5 = 6
        mem[33] = 32'h00600313; // ADDI x6, x0, 6       | x6 = 6
        mem[34] = 32'h00628463; // BEQ  x5, x6, +8      | salta si iguales → mem[36]
        mem[35] = 32'h00100293; // ADDI x5, x0, 1       | (NO ejecuta)
        mem[36] = 32'h00A00393; // ADDI x7, x0, 10      | x7 = 10
        
        // --- SALTO INCONDICIONAL (JAL) ---
        mem[37] = 32'h008000EF; // JAL  x1, +8          | Salta a mem[39], x1=PC+4
        mem[38] = 32'hDEADBEEF; // (dato - NO ejecuta)
        mem[39] = 32'h01400293; // ADDI x5, x0, 20      | x5 = 20
        
        // --- FIN DEL PROGRAMA ---
        mem[40] = 32'h00000013; // NOP
        mem[41] = 32'h00000013; // NOP
        mem[42] = 32'h00000013; // NOP (loop infinito aquí)
        
        // Instrucciones 43-255: NOPs
    end

    // Lectura asíncrona (combinacional)
    // addr está en bytes, pero necesitamos acceso por word (dividir entre 4)
    // addr[31:2] da el índice de la palabra
    assign inst = mem[addr[31:2]];

endmodule
