# 🔧 Procesador RISC-V RV32I Monociclo para FPGA DE1-SoC

Procesador educativo RISC-V de 32 bits implementado en SystemVerilog, optimizado para demostración en FPGA Cyclone V.

---

## 🎯 ¿Qué es este proyecto?

Un procesador **RISC-V monociclo completo y funcional** que:

- ✅ Ejecuta programas RISC-V reales (43 instrucciones de ejemplo incluidas)
- ✅ Se puede programar en FPGA DE1-SoC para demostración interactiva
- ✅ Incluye displays 7 segmentos para visualizar ejecución paso a paso
- ✅ Modo manual (avanza con botón) y automático (1 seg/instrucción)
- ✅ 10 LEDs que indican el tipo de instrucción ejecutándose

**Programa de demostración:** Calcula la suma 1+2+3+4+5=15 usando un loop, muestra operaciones aritméticas, lógicas, shifts, load/store, branches y jumps.

---

## 🚀 Inicio Rápido

### Simular en Icarus Verilog

```powershell
# Compilar y simular
cd rv32i_mono
iverilog -g2012 -o sim/monociclo_tb.vvp tb/monociclo_tb.sv src/*.sv
vvp sim/monociclo_tb.vvp

# Ver resultados finales
vvp sim/monociclo_tb.vvp | Select-Object -Last 30
```

### Programar en FPGA DE1-SoC

1. **Abrir Quartus Prime:**

   - Archivo → Open Project → Navegar a `quartus/rv32i_fpga.qpf`
   - Los pines ya están configurados en `de1_soc_pins.tcl` (no requiere configuración manual)

2. **Compilar:**

   - Processing → Start Compilation (o Ctrl+L)
   - Tiempo: ~19 minutos (completo con timing)
   - Genera `quartus/output_files/rv32i_fpga.sof`

3. **Programar FPGA:**
   - Tools → Programmer
   - Hardware Setup → Seleccionar "DE-SoC [USB-0]" o "USB-Blaster"
   - Si no aparece el .sof: Click "Add File" → Navegar a `quartus/output_files/rv32i_fpga.sof`
   - Marcar checkbox "Program/Configure"
   - Click "Start" para programar

**Nota:** Puedes usar un `.sof` precompilado sin compilar de nuevo. Solo necesitas el paso 3 si ya tienes el archivo `.sof` generado.

**Alternativa por línea de comandos:**

```powershell
cd quartus
quartus_sh --flow compile rv32i_fpga
quartus_pgm -m jtag -o "p;output_files/rv32i_fpga.sof"
```

---

## 🎮 Controles en FPGA

### Botones

- **KEY[0]** = Avanzar un ciclo (modo manual)
- **KEY[1]** = RESET (vuelve a PC=0)

### Switches

- **SW[9]** = Modo: 0=Manual, 1=Automático (1 seg/inst)
- **SW[8]** = Ventana displays: 0=bits [31:24], 1=bits [23:16]
- **SW[7:4]** = Selección de registro (cuando SW[3:0]=0011)
- **SW[3:0]** = Señal a visualizar (ver tabla abajo)

### Displays 7 Segmentos

- **HEX5-4** = Bits variables según ventana (SW[8])
- **HEX3-0** = Bits [15:0] fijos de la señal seleccionada

### LEDs Rojos (LEDR[9:0])

```
LEDR0 = Modo AUTO activo
LEDR1 = Ventana (0=altos, 1=medios)
LEDR2 = Pulso de clock
LEDR3 = Tipo R (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT)
LEDR4 = Tipo I-ALU (ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI)
LEDR5 = LOAD (LW, LH, LB, LHU, LBU)
LEDR6 = STORE (SW, SH, SB)
LEDR7 = BRANCH (BEQ, BNE, BLT, BGE, BLTU, BGEU)
LEDR8 = JAL
LEDR9 = JALR
```

---

## 📊 Señales Visualizables (SW[3:0])

| SW[3:0] | Señal       | Descripción                  |
| ------- | ----------- | ---------------------------- |
| 0000    | PC          | Program Counter              |
| 0001    | Instruction | Instrucción actual           |
| 0010    | ALU Result  | Resultado de la ALU          |
| 0011    | Registro    | Ver registro x1-x7 (SW[7:4]) |
| 0100    | Memoria[0]  | Palabra de memoria 0         |
| 0101    | Memoria[1]  | Palabra de memoria 1         |
| 0110    | Memoria[2]  | Palabra de memoria 2         |
| 0111    | Memoria[3]  | Palabra de memoria 3         |
| 1000    | ALU A       | Entrada A de la ALU          |
| 1001    | ALU B       | Entrada B de la ALU          |
| 1010    | Next PC     | Próximo valor del PC         |

**Ejemplo:** Para ver x3 (resultado del loop): `SW[9:0] = 0000110011`

---

## 🏗️ Arquitectura


**13 módulos principales:**

1. `pc.sv` - Program Counter
2. `sum.sv` - Sumador (PC + 4)
3. `im.sv` - Instruction Memory (256 palabras)
4. `cu.sv` - Control Unit (decodifica instrucciones)
5. `ru.sv` - Register Unit (32 registros x 32 bits)
6. `immgen.sv` - Immediate Generator
7. `muxaluA.sv` - Mux entrada A de ALU
8. `muxaluB.sv` - Mux entrada B de ALU
9. `bru.sv` - Branch Unit (decisiones de salto)
10. `alu.sv` - Arithmetic Logic Unit
11. `muxnextpc.sv` - Mux Next PC
12. `dm.sv` - Data Memory (256 palabras)
13. `muxrudata.sv` - Mux Write Data

**Top-level:** `monociclo.sv` integra todo + `fpga_top.sv` para FPGA

### Módulos Adicionales para FPGA

Para adaptar el procesador a la FPGA DE1-SoC, se añadieron módulos auxiliares:

1. **`fpga_top.sv`** - Top-level de FPGA que instancia:
   - `monociclo.sv` - Procesador completo
   - `clock_divider.sv` - Reduce 50 MHz a 1 Hz (modo automático)
   - `debouncer.sv` - Elimina rebotes de botones (20 ms)
   - `edge_detector.sv` - Detecta flancos de bajada de botones
   - `hex_decoder.sv` - Decodifica 4 bits a 7 segmentos
   - `hex_display_6.sv` - Controlador de 6 displays HEX5-0

2. **Función de cada módulo:**
   - **Clock Divider:** Permite visualizar ejecución a velocidad humana (1 instrucción/segundo)
   - **Debouncer:** Evita lecturas múltiples por rebote mecánico de botones
   - **Edge Detector:** Genera pulso único por presión de botón (modo manual)
   - **Hex Display:** Muestra valores hexadecimales en displays 7 segmentos

Estos módulos son esenciales para la interfaz usuario-FPGA, permitiendo control manual/automático y visualización en tiempo real.

---

## 📝 Programa de Demostración

El programa en `src/im.sv` (43 instrucciones) demuestra:

1. **Loop (mem[0-7]):** Suma 1+2+3+4+5 = 15 → guardado en mem[0]
2. **Aritmética (mem[8-11]):** ADD, SUB con valores 10, 20
3. **Lógica (mem[12-16]):** AND, OR, XOR con 0xFF y 0xF0
4. **Shifts (mem[17-21]):** SLLI, SRLI, SRAI
5. **Load/Store (mem[22-31]):** Escribe/lee 42 y 85 en mem[2] y mem[3]
6. **Branch (mem[32-36]):** BEQ condicional
7. **JAL (mem[37-39]):** Salto incondicional (salta DEADBEEF)

---

## 🧪 Testing

Cada módulo tiene su testbench en `tb/`:

```powershell
# Simular módulo individual
iverilog -g2012 -o sim/alu_tb.vvp tb/alu_tb.sv src/alu.sv
vvp sim/alu_tb.vvp

# Ver formas de onda
gtkwave vcd/alu_tb.vcd
```

---

## 📁 Estructura del Proyecto

```
rv32i_mono/
├── src/              # Módulos del procesador (*.sv)
├── tb/               # Testbenches
├── sim/              # Archivos compilados (.vvp)
├── vcd/              # Formas de onda (.vcd)
├── quartus/          # Proyecto Quartus Prime
│   ├── output_files/ # Bitstream (.sof)
│   ├── de1_soc_pins.tcl
│   └── rv32i_fpga.qpf
├── docs/             # Documentación
│   ├── Tablas.md
│   └── notes.md
└── readme.md
```

---

## 📚 Documentación Adicional

- **[Tabla de Configuraciones](docs/Tablas.md)** - Referencia de switches y LEDs
- **[Notas](docs/notes.md)** - Detalles de implementación

---

## 🐛 Bugs Corregidos

Durante el desarrollo se encontraron y corrigieron:

1. ADDI con campo rs1 incorrecto (0→1)
2. BLT con opcode de STORE (0x23→0x63)
3. Control Unit: ImmSrc incorrecto para branches y JAL
4. Control Unit: Muxes ALU incorrectos para branches
5. BRU: JAL no saltaba (nextPCSrc=0 en lugar de 1)
6. Límite de loop (x2=5→6 para sumar hasta 5)



## 👨‍💻 Autor

Camilo Eduardo Muñoz Albornoz  
Proyecto Monociclo RISC-V RV32I - Arquitectura de Computadores  
Universidad Tecnológica de Pereira - 2025

**Herramientas:**

- Icarus Verilog 12.0
- Quartus Prime 24.1 Lite
- VS Code + SystemVerilog extension

---