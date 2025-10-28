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

![Resultado ALU Testbench](../snapshots/alu_tb.png)

---
