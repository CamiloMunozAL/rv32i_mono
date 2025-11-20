# ============================================================================
# Script TCL de Configuración Optimizada para Quartus
# ============================================================================
# Este script configura Quartus para compilación más rápida
# Ejecutar desde: Tools > Tcl Scripts > quartus_settings.tcl
# ============================================================================

# ============================================================================
# CONFIGURACIONES BÁSICAS
# ============================================================================

# Establecer familia y dispositivo
set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CSEMA5F31C6
set_global_assignment -name TOP_LEVEL_ENTITY fpga_top

# NOTA: Los archivos .sv ya fueron agregados manualmente
# Si necesitas agregarlos automáticamente, descomenta las siguientes líneas:

# set_global_assignment -name SYSTEMVERILOG_FILE ../src/fpga_top.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/debouncer.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/edge_detector.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/clock_divider.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/hex_display_6.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/hex_decoder.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/signal_selector.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/monociclo.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/pc.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/sum.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/im.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/cu.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/ru.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/immgen.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/muxaluA.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/muxaluB.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/bru.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/alu.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/muxnextpc.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/dm.sv
# set_global_assignment -name SYSTEMVERILOG_FILE ../src/muxrudata.sv

# Archivo de restricciones de tiempo
set_global_assignment -name SDC_FILE DE1_SoC.sdc

# ============================================================================
# OPTIMIZACIONES DE COMPILACIÓN (REDUCIR ÁREA)
# ============================================================================

# Nivel de optimización: AGRESIVO para área (crítico para caber en FPGA)
set_global_assignment -name OPTIMIZATION_MODE "AGGRESSIVE AREA"

# Maximizar esfuerzo del fitter para optimizar área
set_global_assignment -name FITTER_EFFORT "STANDARD FIT"

# Habilitar compilación incremental (solo recompila lo que cambió)
set_global_assignment -name INCREMENTAL_COMPILATION OFF

# Optimización de síntesis para ÁREA
set_global_assignment -name OPTIMIZATION_TECHNIQUE AREA

# Physical synthesis optimizations (ACTIVAR para reducir área)
set_global_assignment -name PHYSICAL_SYNTHESIS_COMBO_LOGIC ON
set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION OFF
set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_RETIMING ON
set_global_assignment -name PHYSICAL_SYNTHESIS_EFFORT EXTRA

# ============================================================================
# CONFIGURACIONES DE TIMING
# ============================================================================

# TimeQuest Timing Analyzer
set_global_assignment -name TIMEQUEST_MULTICORNER_ANALYSIS ON
set_global_assignment -name TIMEQUEST_DO_CCPP_REMOVAL ON

# Smart compilation (compilación inteligente)
set_global_assignment -name SMART_RECOMPILE ON

# ============================================================================
# CONFIGURACIONES DE FITTER
# ============================================================================

# Permitir que el fitter use cualquier pin (más rápido)
set_global_assignment -name AUTO_RESOURCE_SHARING ON

# Seed para resultados reproducibles (cambiar si fitter falla)
set_global_assignment -name SEED 1

# ============================================================================
# POWER ANALYSIS (DESACTIVAR PARA COMPILACIÓN RÁPIDA)
# ============================================================================

set_global_assignment -name FLOW_ENABLE_POWER_ANALYZER OFF
set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"

# ============================================================================
# CONFIGURACIONES DE MENSAJES
# ============================================================================

# Reducir warnings innecesarios
set_global_assignment -name ENABLE_SIGNALTAP OFF
set_global_assignment -name ENABLE_LOGIC_ANALYZER_INTERFACE OFF

# Ignorar warnings de timing para clocks muy lentos
set_global_assignment -name CUT_OFF_PATHS_BETWEEN_CLOCK_DOMAINS ON

# ============================================================================
# PARTICIONES (Para diseños grandes)
# ============================================================================

# Crear particiones para compilación incremental
set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top
set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top

# ============================================================================
# OPTIMIZACIONES ESPECÍFICAS PARA ESTE DISEÑO
# ============================================================================

# Forzar uso de bloques M10K para memorias (ahorrar lógica)
set_global_assignment -name AUTO_RAM_RECOGNITION ON
set_global_assignment -name AUTO_RAM_TO_LCELL_CONVERSION OFF

# Optimizar agresivamente para área (reducir uso de LUTs)
set_global_assignment -name ADV_NETLIST_OPT_SYNTH_WYSIWYG_REMAP ON
set_global_assignment -name REMOVE_REDUNDANT_LOGIC_CELLS ON
set_global_assignment -name AUTO_RESOURCE_SHARING ON

# Permitir retiming y restructuración para reducir área
set_global_assignment -name SYNTH_TIMING_DRIVEN_SYNTHESIS OFF
set_global_assignment -name ROUTER_TIMING_OPTIMIZATION_LEVEL MINIMUM

# Mapeo de multiplicadores y DSPs
set_global_assignment -name AUTO_DSP_RECOGNITION ON

# Compartir recursos entre operaciones similares
set_global_assignment -name STATE_MACHINE_PROCESSING "USER-ENCODED"
set_global_assignment -name SAFE_STATE_MACHINE OFF

# ============================================================================
# CONFIGURACIÓN DE NUM_PARALLEL_PROCESSORS
# ============================================================================

# Usar todos los cores disponibles (ajustar según tu PC)
# Descomentar y ajustar el número según tu CPU:
# set_global_assignment -name NUM_PARALLEL_PROCESSORS 4

# Auto-detectar número de procesadores
set_global_assignment -name NUM_PARALLEL_PROCESSORS ALL

puts "Configuración optimizada aplicada exitosamente"
puts "MODO: Optimización AGRESIVA de ÁREA para caber en Cyclone V"
puts "Tiempo de compilación estimado: 5-15 minutos (primera vez)"
puts "Uso de lógica esperado: ~25K-30K logic cells (antes: 55K)"
