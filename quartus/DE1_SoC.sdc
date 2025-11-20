# ============================================================================
# Synopsys Design Constraints (SDC) for DE1-SoC
# ============================================================================
# Este archivo define restricciones de tiempo para optimizar la compilación
# y garantizar que el diseño funcione correctamente a las frecuencias deseadas
# ============================================================================

# ============================================================================
# RELOJES
# ============================================================================

# Clock principal de 50 MHz (periodo = 20 ns)
create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]

# Clocks generados internamente
# Clock dividido para modo automático 1Hz (periodo muy largo, no crítico)
# create_generated_clock -name clk_1hz \
#     -source [get_ports {CLOCK_50}] \
#     -divide_by 25000000 \
#     [get_registers {clk_div_1hz|clk_out}]

# Clock dividido para modo automático 10Hz
# create_generated_clock -name clk_10hz \
#     -source [get_ports {CLOCK_50}] \
#     -divide_by 2500000 \
#     [get_registers {clk_div_10hz|clk_out}]

# ============================================================================
# GRUPOS DE CLOCKS
# ============================================================================

# Estos clocks son asincrónicos entre sí (no se deben analizar paths entre ellos)
# set_clock_groups -asynchronous \
#     -group {CLOCK_50} \
#     -group {clk_1hz} \
#     -group {clk_10hz}

# ============================================================================
# INCERTIDUMBRE DE CLOCK (Clock Uncertainty)
# ============================================================================

# Agregar margen de seguridad para jitter y skew
# set_clock_uncertainty -setup 0.100 [get_clocks CLOCK_50]
# set_clock_uncertainty -hold 0.100 [get_clocks CLOCK_50]

# ============================================================================
# LATENCIAS DE CLOCK
# ============================================================================

# Latencia de la red de clock (estimación conservadora)
# set_clock_latency -source 2.000 [get_clocks CLOCK_50]
# set_clock_latency 1.000 [get_clocks CLOCK_50]

# ============================================================================
# RESTRICCIONES DE ENTRADA (Input Constraints)
# ============================================================================

# Los botones y switches son entradas asíncronas
# Definir tiempo máximo de llegada después del flanco de clock
set_input_delay -clock CLOCK_50 -max 2.000 [get_ports {KEY[*]}]
set_input_delay -clock CLOCK_50 -min 0.000 [get_ports {KEY[*]}]

set_input_delay -clock CLOCK_50 -max 2.000 [get_ports {SW[*]}]
set_input_delay -clock CLOCK_50 -min 0.000 [get_ports {SW[*]}]

# ============================================================================
# RESTRICCIONES DE SALIDA (Output Constraints)
# ============================================================================

# LEDs y displays tienen bastante tiempo para estabilizarse
set_output_delay -clock CLOCK_50 -max 5.000 [get_ports {LEDR[*]}]
set_output_delay -clock CLOCK_50 -min -1.000 [get_ports {LEDR[*]}]

set_output_delay -clock CLOCK_50 -max 5.000 [get_ports {HEX0[*]}]
set_output_delay -clock CLOCK_50 -min -1.000 [get_ports {HEX0[*]}]

set_output_delay -clock CLOCK_50 -max 5.000 [get_ports {HEX1[*]}]
set_output_delay -clock CLOCK_50 -min -1.000 [get_ports {HEX1[*]}]

set_output_delay -clock CLOCK_50 -max 5.000 [get_ports {HEX2[*]}]
set_output_delay -clock CLOCK_50 -min -1.000 [get_ports {HEX2[*]}]

set_output_delay -clock CLOCK_50 -max 5.000 [get_ports {HEX3[*]}]
set_output_delay -clock CLOCK_50 -min -1.000 [get_ports {HEX3[*]}]

set_output_delay -clock CLOCK_50 -max 5.000 [get_ports {HEX4[*]}]
set_output_delay -clock CLOCK_50 -min -1.000 [get_ports {HEX4[*]}]

set_output_delay -clock CLOCK_50 -max 5.000 [get_ports {HEX5[*]}]
set_output_delay -clock CLOCK_50 -min -1.000 [get_ports {HEX5[*]}]

# ============================================================================
# FALSE PATHS (Caminos que no necesitan análisis de tiempo)
# ============================================================================

# Las señales de reset son asíncronas
set_false_path -from [get_ports {KEY[1]}] -to *

# Los switches de configuración no son críticos en tiempo
set_false_path -from [get_ports {SW[*]}] -to [get_ports {LEDR[*]}]
set_false_path -from [get_ports {SW[*]}] -to [get_ports {HEX*[*]}]

# Las salidas de debug no son críticas
set_false_path -from * -to [get_ports {LEDR[9] LEDR[8] LEDR[7] LEDR[6] LEDR[5] LEDR[4]}]

# ============================================================================
# MULTICYCLE PATHS
# ============================================================================

# El procesador es monociclo, pero en modo manual el clock puede ser muy lento
# No necesitamos restricciones estrictas para el path del procesador cuando
# usa clock manual (edge_detector)

# ============================================================================
# CONFIGURACIONES ADICIONALES
# ============================================================================

# Derivar automáticamente restricciones de clock para clocks generados internamente
# derive_pll_clocks
derive_clock_uncertainty

# No analizar paths entre dominios de clock diferentes
# set_false_path -from [get_clocks {CLOCK_50}] -to [get_clocks {clk_1hz}]
# set_false_path -from [get_clocks {CLOCK_50}] -to [get_clocks {clk_10hz}]
# set_false_path -from [get_clocks {clk_1hz}] -to [get_clocks {CLOCK_50}]
# set_false_path -from [get_clocks {clk_10hz}] -to [get_clocks {CLOCK_50}]

# ============================================================================
# NOTAS
# ============================================================================
# - El diseño está optimizado para funcionar a 50MHz
# - Los clocks divididos (1Hz, 10Hz) no tienen restricciones críticas
# - Las entradas/salidas tienen márgenes generosos ya que son señales lentas
# - Se marcan como false paths las señales que no necesitan timing crítico
