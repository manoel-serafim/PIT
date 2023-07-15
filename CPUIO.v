`include "CPU.v"


module CPUIO(

	/* Clock Signal */
  input clock_50,
  input [3:0] KEY,
  input n_reset,
  output [0:17]LEDR
  
  

);


  

  wire CLOCK;
  wire [31:0] DATA_OUT_1;
  wire [31:0] DATA_OUT_2;
  
  /* Wires to connect instruction memory to CPU */
  wire [31:0] instructionPC;
  wire [31:0] instructionOut;

  /* wires to connect registers to CPU */
  wire [4:0] ADDR_REG_1;
  wire [4:0] ADDR_REG_2;
  wire [4:0] ADDR_WRITE_REG;
  wire [31:0] WRITE_DATA;
  

  /* Wires to connect Data Memory to CPU */
  wire [31:0] READ_DATA_MEM;
  wire [31:0] ALU_OUT;
  wire CONTROL_LEDWRITE;

   /* Wires to connect CPU Control Lines to Memories */
  wire CONTROL_REG2LOC;
  wire CONTROL_REGWRITE;
  wire CONTROL_MEMREAD;
  wire CONTROL_MEMWRITE;
  wire CONTROL_NBRANCH;
  wire CONTROL_ZBRANCH;
  wire RESET_REG;
	
  DeBounce DB(clock_50, n_reset, KEY[0], CLOCK);

  /* Instruction Memory Module */
  INSTmem mem1
  (
    instructionPC,
    instructionOut
  );

  /* Registers Module */
  REG mem2
  (
    ADDR_REG_1,
    ADDR_REG_2,
    ADDR_WRITE_REG,
    WRITE_DATA,
	 RESET_REG,
    CONTROL_REGWRITE,
    DATA_OUT_1,
    DATA_OUT_2
  );

  /* Data Memory Module */
  DATmem mem3
  (
    ALU_OUT,
    DATA_OUT_2,
    CONTROL_MEMREAD,
    CONTROL_MEMWRITE,
    READ_DATA_MEM
  );

  /* CPU Module */
  CPU core
  (
    .CLOCK(CLOCK),
    .INSTRUCTION(instructionOut),
    .PC(instructionPC),
    .CONTROL_REG2LOC(CONTROL_REG2LOC),
    .CONTROL_REGWRITE(CONTROL_REGWRITE),
    .CONTROL_MEMREAD(CONTROL_MEMREAD),
    .CONTROL_MEMWRITE(CONTROL_MEMWRITE),
    .CONTROL_NBRANCH(CONTROL_NBRANCH),
	 .CONTROL_ZBRANCH(CONTROL_ZBRANCH),
    .ADDR_REG_1(ADDR_REG_1),
    .ADDR_REG_2(ADDR_REG_2),
    .ADDR_WRITE_REG(ADDR_WRITE_REG),
    .REG_DATA_1(DATA_OUT_1),
    .REG_DATA_2(DATA_OUT_2),
    .ALU_OUT(ALU_OUT),
    .READ_DATA_MEM(READ_DATA_MEM),
    .WRITE_REG_DATA(WRITE_DATA),
	 .CONTROL_LEDWRITE(CONTROL_LEDWRITE)
  );
  
  LEDOUT leds
  (
	 DATA_OUT_1,
    DATA_OUT_2,
	 CLOCK,
	 CONTROL_LEDWRITE,
	 LEDR
  );


endmodule
