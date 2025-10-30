/*Register unit
Recordar mantener x0 siempre en 0
	5. Registers unit
		a. Input: rs1,rs2,rd, DataWr,RUWr
		b. Output: RU[rs1], RU[rs2]
Descripcion: almacena los 32 registros de proposito general, lee rs1 y rs2 y escribe en rd si RUWr es 1
*/

module ru(
  input logic clk, //Reloj
  input logic [4:0] rs1, //Registro fuente 1
  input logic [4:0] rs2, //Registro fuente 2
  input logic [4:0] rd, //Registro destino
  input logic [31:0] DataWr, //Dato a escribir
  input logic RUWr, //Señal de control para escribir en el banco de registros
  output logic [31:0] RU_rs1, //Dato del registro fuente 1
  output logic [31:0] RU_rs2 //Dato del registro fuente 2
  );

  //En risc V la arquitectura usa 32 registros de 32 bits, se puede ver como una matriz de 32 registros x 32 bits

  logic [31:0] RU [31:0]; //Banco de registros
  initial begin
    integer i;
    for(i = 0; i<32; i=i+1)begin
      RU[i] = 32'b0; //Inicializar todos los registros a 0
    end
    RU[2] = 32'b11111111111111111111111111111111; // porque vamos a usar el stack ponter y restarle para reservar espacio en la pila (x2 empieza en la posicion mas alta de la memoria)
  end

  //Lectura asincronica
  assign RU_rs1 = RU[rs1]; //Lectura del registro fuente 1
  assign RU_rs2 = RU[rs2]; //Lectura del registro fuente 2

  //Escritura sincronica
  always_ff @(posedge clk) begin
    if (RUWr && (rd != 0)) begin //Si la señal de control es alta y el registro destino no es 0
      RU[rd] <= DataWr; //Escritura del dato en el registro destino
    end
  end
endmodule
//Nota: El registro x0 (registro 0) siempre debe contener el valor 0
