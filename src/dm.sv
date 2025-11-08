/*
Modulo para la data memory (dm)
inputs:
- 32 bits de la dirección (addr) de la ALU
- 32 bits de los datos a escribir (DataWr) desde la unidad de registros ru[rs2]
control:
- 1 bit para habilitar la escritura (DMWr)
- 3 bits para DMCtrl (tipo de acceso: byte, halfword, word, signado o no signado)
outputs:
- 32 bits de los datos leídos (DataRd)

DMCtrl
B->000: LB (load byte signed)
H->001: LH (load halfword signed)
W->010: LW (load word signed)
BU->100: LBU (load byte unsigned)
HU->101: LHU (load halfword unsigned)

*/

module dm (
    input  logic        clk,        // reloj del sistema
    input  logic        DMWr,       // enable de escritura
    input  logic [2:0]  DMCtrl,     // tipo de acceso
    input  logic [31:0] addr,       // dirección desde la ALU
    input  logic [31:0] DataWr,     // dato a escribir
    output logic [31:0] DataRd,     // dato leído
    output logic [31:0] debug_dm_word [0:7] // debug: primeros 8 words
);

    // Memoria de 8 KiB (8192 bytes)
    logic [7:0] mem [0:8191];

    // Inicializar memoria a 0
    initial begin
        integer i;
        for (i = 0; i < 8192; i = i + 1) begin
            mem[i] = 8'h00;
        end
    end

    // Debug: exportar los primeros 8 words como outputs
    genvar dbg_i;
    generate
        for (dbg_i = 0; dbg_i < 8; dbg_i = dbg_i + 1) begin : dm_dbg
            assign debug_dm_word[dbg_i] = {mem[4*dbg_i+3], mem[4*dbg_i+2], mem[4*dbg_i+1], mem[4*dbg_i+0]};
        end
    endgenerate

    // Aliases para lectura (más legible y compatible con Icarus)
    logic [7:0] b0, b1, b2, b3;
    assign b0 = mem[addr];
    assign b1 = mem[addr + 1];
    assign b2 = mem[addr + 2];
    assign b3 = mem[addr + 3];

    //========================================================
    // LECTURA COMBINACIONAL (sin reloj)
    //========================================================
    assign DataRd =
        (DMCtrl == 3'b000) ? {{24{b0[7]}}, b0} :                // LB
        (DMCtrl == 3'b001) ? {{16{b1[7]}}, b1, b0} :            // LH
        (DMCtrl == 3'b010) ? {b3, b2, b1, b0} :                 // LW
        (DMCtrl == 3'b100) ? {24'b0, b0} :                      // LBU
        (DMCtrl == 3'b101) ? {16'b0, b1, b0} :                  // LHU
                             32'b0;

    //========================================================
    // ESCRITURA SINCRÓNICA (con reloj)
    //========================================================
    always_ff @(posedge clk) begin
        if (DMWr) begin
            case (DMCtrl)
                3'b000: mem[addr] <= DataWr[7:0];                       // SB
                3'b001: begin                                           // SH
                    mem[addr]     <= DataWr[7:0];
                    mem[addr + 1] <= DataWr[15:8];
                end
                3'b010: begin                                           // SW
                    mem[addr]     <= DataWr[7:0];
                    mem[addr + 1] <= DataWr[15:8];
                    mem[addr + 2] <= DataWr[23:16];
                    mem[addr + 3] <= DataWr[31:24];
                end
            endcase
        end
    end

endmodule
