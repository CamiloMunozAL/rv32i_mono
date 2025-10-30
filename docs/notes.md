# 🧠 Informe de Observaciones, Dificultades, Soluciones y Conclusiones

**Laboratorio 1 – Implementación del Procesador Monociclo RISC-V (RV32I)**  
Arquitectura de Computadores – Universidad Tecnológica de Pereira

---

## 📘 Introducción

En este documento se registrarán de manera progresiva las observaciones, dificultades encontradas, soluciones aplicadas y conclusiones obtenidas durante el desarrollo del procesador monociclo RISC-V (RV32I).  
El propósito es mantener un registro detallado del proceso de construcción, verificación y análisis de cada módulo, siguiendo la metodología planteada en el laboratorio.

---

## 🎯 Objetivos

- Implementar los módulos fundamentales del procesador monociclo (ALU, Banco de registros, Unidad de control, Memorias, etc.).
- Verificar su funcionamiento mediante testbench en **Icarus Verilog**.
- Analizar las señales de simulación en **WaveTrace (VSCode)**.
- Documentar de forma progresiva las dificultades y soluciones durante el desarrollo.

---

## 📝 Registro de Desarrollo

### 1️⃣ ALU (Arithmetic Logic Unit)

Se implementó la Unidad Aritmético-Lógica como módulo combinacional con entradas de 32 bits (`A`, `B`) y selector de operación de 4 bits (`ALUOp`). Soporta 11 operaciones: suma, resta, desplazamientos (lógicos y aritmético), comparaciones (signed/unsigned) y operaciones lógicas (AND, OR, XOR). Se desarrolló un testbench (`alu_tb.sv`) que verifica todas las operaciones con casos representativos incluyendo números positivos, negativos y operaciones de bits. Todas las pruebas fueron exitosas.

**Resultado del testbench:**

![Resultado ALU Testbench](../img/alu_tb.png)

---

### 2️⃣ Program Counter (PC)

Se implementó el Program Counter como módulo secuencial que almacena la dirección de la instrucción actual. Utiliza un flip-flop de 32 bits con señal de reloj (`clk`) y reset asíncrono (`reset`). La entrada `next_pc` permite actualizar la dirección en cada ciclo de reloj. Al activar reset, el PC se reinicia a 0x00000000. Se desarrolló un testbench (`pc_tb.sv`) que verifica la actualización secuencial del PC, la funcionalidad de reset y la carga de diferentes direcciones. Todas las pruebas fueron exitosas.

**Resultado del testbench:**

![Resultado PC Testbench](../img/pc_tb.png)

---

### 3️⃣ Sumador (Sum)

Se implementó un módulo combinacional que incrementa en 4 la dirección del Program Counter (PC). Este módulo es esencial para avanzar a la siguiente instrucción en el flujo de ejecución del procesador.

El diseño utiliza una operación combinacional simple para sumar 4 a la entrada `pc_in` y producir la salida `pc_out`.

#### 🧪 Testbench del Sumador

Se desarrolló un testbench (`sum_tb.sv`) que verifica:

- ✅ Incremento correcto de la dirección del PC en 4.
- ✅ Manejo de valores límite, como `0xFFFFFFFC`.

**Resultado del testbench:**

![Resultado Sumador Testbench](../img/sum_tb.png)

---

### 4️⃣ Unidad de Control (Control Unit)

La Unidad de Control fue diseñada como un módulo combinacional encargado de decodificar las instrucciones RISC-V y generar todas las señales de control necesarias para el procesador monociclo. Se analizaron los diferentes formatos de instrucción (R, I, S, B, U, J) y se implementó una lógica basada en un bloque `case` sobre el campo `opcode`, complementada con los campos `funct3` y `funct7` para distinguir operaciones específicas. Para cada tipo de instrucción, se asignan valores concretos a las señales de control: escritura en registros (`RUWr`), selección de inmediato (`ImmSrc`), fuentes de la ALU (`AluAsrc`, `AluBsrc`), operación de salto (`BrOp`), operación de la ALU (`AluOp`), control de memoria de datos (`DmWr`, `DmCtrl`) y fuente de datos para escritura en registros (`RUDataWrSrc`). El diseño se apoyó en tablas de verdad y documentación oficial del set de instrucciones RV32I, asegurando que cada instrucción activa únicamente las señales requeridas para su ejecución.

#### 🧪 Testbench

El testbench se elaboró para verificar el funcionamiento de la Unidad de Control bajo diferentes escenarios representativos. Se instanció el módulo y se inicializaron las señales de entrada (`opcode`, `funct3`, `funct7`). Para cada tipo de instrucción relevante, se asignaron los valores correspondientes y se dejó un retardo para observar la respuesta. Se utilizaron `$display` para mostrar en consola los valores de las señales de salida más importantes, facilitando la depuración y el análisis directo. Además, se generó un archivo VCD con `$dumpfile` y `$dumpvars` para visualizar las ondas en WaveTrace. El testbench cubre instrucciones R-Type (ADD, SUB), I-Type (ADDI, SLTI), Load (LW), Store (SW), Branch (BEQ), Jump (JAL) y un caso inválido, permitiendo comprobar la correcta decodificación y activación de señales en cada caso.

**Resultado del testbench:**

![Resultado Control Unit Testbench](../img/cu_tb.png)

---
