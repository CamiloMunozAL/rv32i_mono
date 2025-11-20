// ============================================================================
// FPGA Top Module for DE1-SoC
// ============================================================================
// Módulo top-level para implementar el procesador RV32I en FPGA DE1-SoC
// 
// Características:
// - Clock manual (botón) o automático (switch)
// - Visualización de señales internas en displays de 7 segmentos
// - LEDs para señales de control
// - Switches para selección de señal a visualizar
// ============================================================================

module fpga_top (
    // Clock y Reset
    input  logic        CLOCK_50,        // Clock de 50MHz
    
    // Botones (activos en bajo)
    input  logic [3:0]  KEY,             // KEY[0]=step ciclo, KEY[1]=reset
    
    // Switches
    input  logic [9:0]  SW,              // SW[3:0]=select, SW[7:4]=reg, SW[9]=modo, SW[8]=ventana bits
    
    // LEDs
    output logic [9:0]  LEDR,            // LEDs rojos para señales de control
    
    // Displays de 7 segmentos (activos en bajo)
    output logic [6:0]  HEX0,            // Display 0 (LSB)
    output logic [6:0]  HEX1,            // Display 1
    output logic [6:0]  HEX2,            // Display 2
    output logic [6:0]  HEX3,            // Display 3
    output logic [6:0]  HEX4,            // Display 4
    output logic [6:0]  HEX5             // Display 5 (MSB)
);

    //========================================================
    // SEÑALES INTERNAS
    //========================================================
    
    // Señales de clock y reset procesadas
    logic cpu_clk;                  // Clock del procesador
    logic cpu_reset;                // Reset sincronizado
    logic auto_mode;                // Modo automático
    
    // Botones debounced
    logic key0_clean, key1_clean;
    logic key0_edge;                // Pulso de clock manual
    logic key1_edge;                // Pulso de reset detectado
    
    // Clock dividido para modo automático
    logic clk_3sec;  // Clock de 3 segundos por ciclo (didáctico)
    logic clk_manual_extended; // Clock manual extendido
    logic [7:0] manual_clock_counter; // Contador para extender pulso manual
    
    // Selector de señal
    logic [3:0]  signal_select;     // Qué señal mostrar
    logic [4:0]  reg_address;       // Dirección de registro (0-31)
    
    // Señales del procesador
    logic [31:0] pc_out;
    logic [31:0] inst_out;
    logic [31:0] alu_result_out;
    logic [31:0] alu_a_out;
    logic [31:0] alu_b_out;
    logic [31:0] next_pc_out;
    logic [31:0] debug_x1, debug_x2, debug_x3, debug_x4, debug_x5, debug_x6, debug_x7;
    logic [31:0] debug_dm_word [0:7];
    
    // Señal seleccionada para display (registrada para reducir lógica)
    logic [31:0] display_data;
    logic [15:0] display_low;       // HEX3-0: siempre bits [15:0]
    logic [7:0]  display_high;      // HEX5-4: bits [31:24] o [23:16] según SW[8]
    
    //========================================================
    // ASIGNACIONES
    //========================================================
    
    assign signal_select = SW[3:0];
    assign reg_address = SW[8:4];  // 5 bits para 32 registros
    
    // Modo automático cuando SW[9] está activo
    assign auto_mode = SW[9];
    
    // Ventana deslizante de visualización
    assign display_low = display_data[15:0];  // Siempre bits menos significativos
    // SW[8]=0 → bits altos [31:24], SW[8]=1 → bits medios [23:16]
    assign display_high = SW[8] ? display_data[23:16] : display_data[31:24];
    
    //========================================================
    // DEBOUNCER PARA BOTONES
    //========================================================
    
    debouncer #(.DEBOUNCE_TIME(1_000_000)) debouncer_key0 (
        .clk(CLOCK_50),
        .rst(~KEY[1]),
        .button_in(KEY[0]),
        .button_out(key0_clean)
    );
    
    debouncer #(.DEBOUNCE_TIME(1_000_000)) debouncer_key1 (
        .clk(CLOCK_50),
        .rst(1'b0),
        .button_in(KEY[1]),
        .button_out(key1_clean)
    );
    
    //========================================================
    // EDGE DETECTOR PARA CLOCK MANUAL
    //========================================================
    
    edge_detector edge_det_key0 (
        .clk(CLOCK_50),
        .rst(~KEY[1]),
        .signal_in(key0_clean),
        .edge_detected(key0_edge)
    );
    
    //========================================================
    // EDGE DETECTOR PARA RESET
    //========================================================
    
    edge_detector edge_det_key1 (
        .clk(CLOCK_50),
        .rst(1'b0),
        .signal_in(key1_clean),
        .edge_detected(key1_edge)
    );
    
    //========================================================
    // DIVISOR DE CLOCK
    //========================================================
    
    // Clock didáctico: 1 segundo por ciclo
    clock_divider #(.DIVIDER(50_000_000)) clk_div_1sec (
        .clk_in(CLOCK_50),
        .rst(~KEY[1]),
        .clk_out(clk_3sec)
    );
    
    //========================================================
    // EXTENSOR DE PULSO MANUAL
    //========================================================
    // Extender el pulso de KEY[0] para que dure suficiente tiempo
    // para que la lógica combinacional se estabilice
    
    always_ff @(posedge CLOCK_50 or posedge reset_triggered) begin
        if (reset_triggered) begin
            manual_clock_counter <= 8'b0;
            clk_manual_extended <= 1'b0;
        end else if (key0_edge) begin
            // Detectamos flanco de KEY[0], iniciar pulso extendido
            manual_clock_counter <= 8'd50; // 50 ciclos de 50MHz = 1 microsegundo
            clk_manual_extended <= 1'b1;
        end else if (manual_clock_counter > 0) begin
            // Mantener el pulso alto mientras el contador esté activo
            manual_clock_counter <= manual_clock_counter - 1;
            clk_manual_extended <= 1'b1;
        end else begin
            // Pulso terminado
            clk_manual_extended <= 1'b0;
        end
    end
    
    //========================================================
    // SELECCIÓN DE CLOCK
    //========================================================
    
    always_comb begin
        if (auto_mode) begin
            // Modo automático: 1 segundos por instrucción
            cpu_clk = clk_3sec;
        end else begin
            // Modo manual: Pulso extendido de KEY[0] o reset
            cpu_clk = clk_manual_extended | key1_edge;
        end
    end
    
    // Reset se activa por el flanco del botón KEY[1]
    // Mantenemos cpu_reset alto por un ciclo cuando se detecta el flanco
    logic reset_triggered;
    
    always_ff @(posedge CLOCK_50 or negedge key1_clean) begin
        if (~key1_clean) begin
            reset_triggered <= 1'b1;
        end else if (reset_triggered && (key0_edge || clk_3sec)) begin
            // Desactivar reset después del siguiente pulso de clock
            reset_triggered <= 1'b0;
        end
    end
    
    assign cpu_reset = reset_triggered;
    
    //========================================================
    // PROCESADOR MONOCICLO
    //========================================================
    
    monociclo cpu (
        .clk(cpu_clk),
        .reset(cpu_reset),
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
    // SELECTOR DE SEÑAL (REGISTRADO - reduce lógica combinacional)
    //========================================================
    
    always_ff @(posedge CLOCK_50) begin
        case (signal_select)
            4'h0: display_data <= pc_out;                    // Program Counter
            4'h1: display_data <= inst_out;                  // Instrucción actual
            4'h2: display_data <= alu_result_out;            // Resultado ALU
            4'h3: begin // Registros x1-x7
                case (reg_address[2:0])
                    3'd0: display_data <= 32'h0;       // x0 siempre 0
                    3'd1: display_data <= debug_x1;
                    3'd2: display_data <= debug_x2;
                    3'd3: display_data <= debug_x3;
                    3'd4: display_data <= debug_x4;
                    3'd5: display_data <= debug_x5;
                    3'd6: display_data <= debug_x6;
                    3'd7: display_data <= debug_x7;
                endcase
            end
            4'h4: display_data <= debug_dm_word[0];          // Memoria palabra 0
            4'h5: display_data <= debug_dm_word[1];          // Memoria palabra 1
            4'h6: display_data <= debug_dm_word[2];          // Memoria palabra 2
            4'h7: display_data <= debug_dm_word[3];          // Memoria palabra 3
            4'h8: display_data <= alu_a_out;                 // ALU entrada A
            4'h9: display_data <= alu_b_out;                 // ALU entrada B
            4'hA: display_data <= next_pc_out;               // Siguiente PC
            4'hB: display_data <= {25'b0, inst_out[6:0]};    // opcode
            4'hC: display_data <= {16'b0, inst_out[31:25], inst_out[11:7]}; // rd y funct7
            4'hD: display_data <= {16'b0, inst_out[24:20], inst_out[19:15], inst_out[14:12]}; // rs2, rs1, funct3
            4'hE: display_data <= {29'b0, reg_address[2:0]}; // Mostrar dirección de reg (0-7)
            4'hF: display_data <= 32'hDEADBEEF;              // Debug pattern
            default: display_data <= 32'h00000000;
        endcase
    end
    
    //========================================================
    // DISPLAYS DE 7 SEGMENTOS - Ventana Deslizante
    //========================================================
    // HEX3-0: Siempre bits [15:0] (números pequeños completos)
    // HEX5-4: SW[8]=0 → bits [31:24] | SW[8]=1 → bits [23:16]
    
    hex_display_6 hex_display (
        .value({display_high, display_low}),  // Concatenar ventana alta + baja
        .hex0(HEX0),
        .hex1(HEX1),
        .hex2(HEX2),
        .hex3(HEX3),
        .hex4(HEX4),
        .hex5(HEX5)
    );
    
    //========================================================
    // LEDs DE ESTADO - Indicadores didácticos
    //========================================================
    
    assign LEDR[0] = auto_mode;              // Modo: 0=Manual, 1=Auto
    assign LEDR[1] = SW[8];                  // Ventana: 0=bits altos, 1=bits medios
    assign LEDR[2] = cpu_clk;                // Pulso de clock visible
    assign LEDR[3] = (inst_out[6:0] == 7'b0110011); // Tipo R
    assign LEDR[4] = (inst_out[6:0] == 7'b0010011); // Tipo I (ALU)
    assign LEDR[5] = (inst_out[6:0] == 7'b0000011); // LOAD
    assign LEDR[6] = (inst_out[6:0] == 7'b0100011); // STORE
    assign LEDR[7] = (inst_out[6:0] == 7'b1100011); // BRANCH
    assign LEDR[8] = (inst_out[6:0] == 7'b1101111); // JAL
    assign LEDR[9] = (inst_out[6:0] == 7'b1100111); // JALR

endmodule
