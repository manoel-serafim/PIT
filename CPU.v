`timescale 1ns / 1ps

module CPU
(
  input CLOCK,
  input [31:0] INSTRUCTION,
  input [31:0] REG_DATA_1,
  input [31:0] REG_DATA_2,
  input [31:0] READ_DATA_MEM,
  output reg CONTROL_REG2LOC,
  output reg CONTROL_REGWRITE,
  output reg CONTROL_MEMREAD,
  output reg CONTROL_MEMWRITE,
  output reg CONTROL_ZBRANCH,
  output reg CONTROL_NBRANCH,
  output reg [3:0] ADDR_REG_1,
  output [3:0] ADDR_REG_2,
  output reg [3:0] ADDR_WRITE_REG,
  output [31:0] ALU_OUT,
  output [31:0] WRITE_REG_DATA,
  output reg [31:0] PC
);

  reg [3:0] INST_REG_ADDR1;
  reg [3:0] INST_REG_ADDR2;

  reg CONTROL_MEM2REG;
  reg CONTROL_ALUSRC;
  reg CONTROL_UNCON_BRANCH;
  reg[3:0] ALU_CONTROL;
  
  wire ALU_ZFLAG;
  wire ALU_NFLAG;
  
  wire[31:0] ALU_IN_B;
  wire[31:0] EXT_IMMED;
  wire [31:0] PC_SHIFT_AMMOUNT;

  wire [31:0] BRANCH_PC;
  reg CONTROL_JUMP;
  wire [31:0] NEXT_PC;
  wire NEXT_PC_ZFLAG;
  wire NEXT_PC_NFLAG;
  wire [31:0] SHIFTED_PC;
  wire SHIFTED_PC_ZERO;
  wire SHIFTED_PC_NFLAG;
  reg BRANCH_ON_ZFLAG;
  reg BRANCH_ON_NFLAG;

  /* Multiplexer for the Program Counter */
  PCmux mux1(NEXT_PC, SHIFTED_PC, CONTROL_JUMP, BRANCH_PC);

  /* Multiplexer before the Register */
  REGmux mux2(INST_REG_ADDR1, INST_REG_ADDR2, CONTROL_REG2LOC, ADDR_REG_2);

  /* Multiplexer before the ALU */
  ALUmux mux3(REG_DATA_2, EXT_IMMED, CONTROL_ALUSRC, ALU_IN_B);

  /* Multiplexer after the Data memory */
  DATmemmux mux4(READ_DATA_MEM, ALU_OUT, CONTROL_MEM2REG, WRITE_REG_DATA);

  /* Sign Extention Module */
  SIGNEXT mod1(INSTRUCTION,CLOCK, EXT_IMMED);
  
  /* ALU Result between the Registers and the Data Memory */
  ALU aluResult(REG_DATA_1, ALU_IN_B, ALU_CONTROL, ALU_OUT, ALU_ZFLAG, ALU_NFLAG);

  /* An ALU module to calulcate the next sequential PC */
  ALU adderNextPC(PC, 32'h00000001, 4'b0010, NEXT_PC, NEXT_PC_ZFLAG, NEXT_PC_NFLAG);

  /* An ALU module to calulcate a shifted PC */
  ALU adderShiftPC(PC, PC_SHIFT_AMMOUNT, 4'b0010, SHIFTED_PC, SHIFTED_PC_ZERO, SHIFTED_PC_NFLAG);


  /* Initialize when the CPU is first run */
  initial begin
    PC = 0;
    CONTROL_REG2LOC = 1'bz;
    CONTROL_MEM2REG = 1'bz;
    CONTROL_REGWRITE = 1'bz;
    CONTROL_MEMREAD = 1'bz;
    CONTROL_MEMWRITE = 1'bz;
    CONTROL_ALUSRC = 1'bz;
    CONTROL_ZBRANCH = 1'b0;
	  CONTROL_NBRANCH = 1'b0;
    CONTROL_UNCON_BRANCH = 1'b0;
    BRANCH_ON_ZFLAG = ALU_ZFLAG & CONTROL_ZBRANCH;
	  BRANCH_ON_NFLAG = ALU_NFLAG & CONTROL_NBRANCH; 
    CONTROL_JUMP = CONTROL_UNCON_BRANCH | BRANCH_ON_ZFLAG | BRANCH_ON_NFLAG;
  end

  /* Parse and set the CPU's Control bits */
  always @(posedge CLOCK) begin //or INSTRUCTION

    // Set the PC to the jumped value
    if (CONTROL_JUMP == 1'b1) begin
      PC = #1 BRANCH_PC - 1;
    end

    // Parse the incoming instruction for a given PC
    INST_REG_ADDR1 = INSTRUCTION[19:16];
    INST_REG_ADDR2 = INSTRUCTION[3:0];
    ADDR_REG_1 = INSTRUCTION[7:4];
    ADDR_WRITE_REG = INSTRUCTION[3:0];

    //Control Unit:
    case(INSTRUCTION[31:29])
      3'b000:begin // D-type Instruction
		  CONTROL_ZBRANCH = 1'b0;
		  CONTROL_NBRANCH = 1'b0;
        CONTROL_UNCON_BRANCH = 1'b0;
        //parse based on opcode:
        case(INSTRUCTION[28:21])
          8'b00000000:begin //LDR
            CONTROL_REG2LOC = 1'bx;  //
            CONTROL_MEM2REG = 1'b1;  // Content to load to Rd[0-4]
            CONTROL_REGWRITE = 1'b1;
            CONTROL_MEMREAD = 1'b1;
            CONTROL_MEMWRITE = 1'b0;
            CONTROL_ALUSRC = 1'b1; //addr comes from addr in immediate + data in reg
            ALU_CONTROL = 4'b0010; // sum data in reg to base addr that was given
          end

          8'b00000001:begin //STR
            CONTROL_REG2LOC = 1'b1; //Content to load from Rt[0-4]
            CONTROL_MEM2REG = 1'bx; // no
            CONTROL_REGWRITE = 1'b0; // no
            CONTROL_MEMREAD = 1'b0; //no
            CONTROL_MEMWRITE = 1'b1; //yes
            CONTROL_ALUSRC = 1'b1; // sum the address + content of r1
            ALU_CONTROL = 4'b0010; //sum
          end

        endcase
      end
      3'b001:begin //I-type Instruction
		  CONTROL_ZBRANCH = 1'b0;
		  CONTROL_NBRANCH = 1'b0;
        CONTROL_UNCON_BRANCH = 1'b0;
        case(INSTRUCTION[28:22])
          7'b0000000:begin //MOVI
            CONTROL_REG2LOC = 1'bx; //do not matter
            CONTROL_MEM2REG = 1'b0; // alu output
            CONTROL_REGWRITE = 1'b1; //yes
            CONTROL_MEMREAD = 1'b0; // no
            CONTROL_MEMWRITE = 1'b0; //no
            CONTROL_ALUSRC = 1'b1; // get immediate
            ALU_CONTROL = 4'b0111; //want to just pass the value of the immediate
            end

          7'b0000001:begin //ADDI
            CONTROL_REG2LOC = 1'bx; // do not matter
            CONTROL_MEM2REG = 1'b0; // alu output para Rd[0-4]
            CONTROL_REGWRITE = 1'b1; //yes Rd[0-4]
            CONTROL_MEMREAD = 1'b0; // no
            CONTROL_MEMWRITE = 1'b0; //no
            CONTROL_ALUSRC = 1'b1; // get immediate
            ALU_CONTROL = 4'b0010; //sum Rn[5-9] to immediate and store
            end
        endcase
      end

      3'b010:begin //R-type Instruction
		  CONTROL_ZBRANCH = 1'b0;
		  CONTROL_NBRANCH = 1'b0;
        CONTROL_UNCON_BRANCH = 1'b0;
        case(INSTRUCTION[28:21])
		  
          8'b00000000:begin //ADD
            CONTROL_REG2LOC = 1'b0; // get from Rm[20-16]
            CONTROL_MEM2REG = 1'b0; // alu to Rd[0-4]
            CONTROL_REGWRITE = 1'b1; //yes Rd[0-4]
            CONTROL_MEMREAD = 1'b0; //no
            CONTROL_MEMWRITE = 1'b0; //no
            CONTROL_ALUSRC = 1'b1; //get from r2 data Rm[16-20] 
            ALU_CONTROL = 4'b0010; //sum Rn[5-9] + Rm[20-16] them
          end
          8'b00000001:begin //SUB
            CONTROL_REG2LOC = 1'b0; // get from Rm[20-16]
            CONTROL_MEM2REG = 1'b0; // alu to Rd[0-4]
            CONTROL_REGWRITE = 1'b1; //yes Rd[0-4]
            CONTROL_MEMREAD = 1'b0; //no
            CONTROL_MEMWRITE = 1'b0; //no
            CONTROL_ALUSRC = 1'b1; //get from r2 data Rm[16-20] 
            ALU_CONTROL = 4'b0110; //sub Rn[5-9] - Rm[20-16] them
          end
			 
			 8'b00000001:begin //MOV
            CONTROL_REG2LOC = 1'b0; // get from Rm[20-16]
            CONTROL_MEM2REG = 1'b0; // alu to Rd[0-4]
            CONTROL_REGWRITE = 1'b1; //yes Rd[0-4]
            CONTROL_MEMREAD = 1'b0; //no
            CONTROL_MEMWRITE = 1'b0; //no
            CONTROL_ALUSRC = 1'b1; //get from r2 data Rm[16-20] 
            ALU_CONTROL = 4'b0110; //sub Rn[5-9] - Rm[20-16] them
          end

        endcase
      
      end
      3'b011:begin // CB-type Instruction
		  CONTROL_UNCON_BRANCH = 1'b0;
		
        //parse based on opcode:
        case(INSTRUCTION[28:24])
          5'b00000:begin //BEQ
            CONTROL_REG2LOC = 1'b0;//Rt[0-3]
				CONTROL_MEM2REG = 1'b0;// no
				CONTROL_REGWRITE = 1'b0; // no
				CONTROL_MEMREAD = 1'b0; // no
				CONTROL_MEMWRITE = 1'b0; // no
				CONTROL_ALUSRC = 1'b0; //GET REGVAL
				ALU_CONTROL = 4'b0110; //buff output
				CONTROL_ZBRANCH = 1'b1; //
				CONTROL_NBRANCH = 1'b0;
            
          end

          5'b00001:begin //BLT
            CONTROL_REG2LOC = 1'b0;  // 
            CONTROL_MEM2REG = 1'b0;  // 
            CONTROL_REGWRITE = 1'b1; //
            CONTROL_MEMREAD = 1'b0;  //
            CONTROL_MEMWRITE = 1'b0; //
            CONTROL_ALUSRC = 1'b1;   //
            ALU_CONTROL = 4'b0110;   //
				CONTROL_ZBRANCH = 1'b0; //
				CONTROL_NBRANCH = 1'b1;
            
          end

        endcase
      end

      3'b100:begin // B-type Instruction
        //parse based on opcode:
        case(INSTRUCTION[28:26])
          3'b000:begin //BI
				CONTROL_REG2LOC = 1'b0;//do not really matter
				CONTROL_MEM2REG = 1'b0;// not matter
				CONTROL_REGWRITE = 1'b0;// no
				CONTROL_MEMREAD = 1'b0; // no
				CONTROL_MEMWRITE = 1'b0;//no
				CONTROL_ALUSRC = 1'b0;//no
				ALU_CONTROL = 4'b0111; // buffer
				CONTROL_ZBRANCH = 1'b0; //
				CONTROL_NBRANCH = 1'b0;
				CONTROL_UNCON_BRANCH = 1'b1; // PC = SHIFTED_PC
          end
			 //BL = MOV LR,PC + B ADDR 

          

        endcase
      end

    endcase

    //Determine whether to branch
    BRANCH_ON_ZFLAG = ALU_ZFLAG & CONTROL_ZBRANCH;
	 BRANCH_ON_NFLAG = ALU_NFLAG & CONTROL_NBRANCH;
    CONTROL_JUMP = CONTROL_UNCON_BRANCH | BRANCH_ON_ZFLAG | BRANCH_ON_NFLAG;

    // For non-branch code, set the next sequential PC value
    if (CONTROL_JUMP == 1'b0) begin
    	PC <= #1 BRANCH_PC;
    end
  end
endmodule


//muxes
module PCmux
(
  input [31:0] pcInput,
  input [31:0] shiftInput,
  input CONTROL_JUMP,
  output reg [31:0] pcOut
);

  always @(pcInput, shiftInput, CONTROL_JUMP, pcOut) begin
    if (CONTROL_JUMP == 0) begin
      pcOut = pcInput;
    end

    else begin
      pcOut = shiftInput;
    end
  end
endmodule

module REGmux
(
  input [3:0] addrRm,
  input [3:0] addrRn,
  input CONTROL_REG2LOC,
  output reg [3:0] muxOutput
);

  always @(addrRm, addrRn, CONTROL_REG2LOC) begin

    if (CONTROL_REG2LOC == 0) begin
      muxOutput = addrRm;
    end

    else begin
      muxOutput = addrRn;
    end
  end
endmodule

module ALUmux
(
  input [31:0] register,
  input [31:0] immediate,
  input CONTROL_ALUSRC,
  output reg [31:0] out
);

  always @(register, immediate, CONTROL_ALUSRC, out) begin

    if (CONTROL_ALUSRC == 0) begin
      out = register;
    end

    else begin
      out = immediate;
    end
  end
endmodule

module DATmemmux
(
  input [31:0] readData,
  input [31:0] aluOutput,
  input CONTROL_MEM2REG,
  output reg [31:0] out
);

  always @(readData, aluOutput, CONTROL_MEM2REG, out) begin
    if (CONTROL_MEM2REG == 0) begin
      out = aluOutput;
    end

    else begin
      out = readData;
    end
  end
endmodule





//modules
module SIGNEXT
(
  input [31:0] inputInstruction,
  input CLOCK,
  output reg [31:0] outImmediate
);

    always @(posedge CLOCK) begin

      if (inputInstruction[31:29]== 3'b100) begin // B
        outImmediate[25:0] = inputInstruction[25:0];
        outImmediate[31:26] = {32{outImmediate[25]}};

      end else if (inputInstruction[31:29] == 3'b011) begin // CBZ
        outImmediate[19:0] = inputInstruction[23:5];
        outImmediate[31:20] = {32{outImmediate[19]}};

      end else if (inputInstruction[31:29] == 3'b000) begin // D Type
        outImmediate[12:0] = inputInstruction[20:8]; //address
        outImmediate[31:13] = {32{outImmediate[12]}};

      end else if (inputInstruction[31:29] == 3'b001) begin // I Type
        outImmediate[13:0] = inputInstruction[21:8]; //immediate
        outImmediate[31:14] = {32{outImmediate[13]}};
      end

    end
endmodule

module ALU
(
  input [31:0] A,
  input [31:0] B,
  input [3:0] CONTROL,
  output reg [31:0] RESULT,
  output reg ZFLAG,
  output reg NFLAG
);

  always @(A or B or CONTROL) begin
    case (CONTROL)
      4'b0000 : RESULT = A & B;     //and
      4'b0001 : RESULT = A | B;     //or
      4'b0010 : RESULT = A + B;     //sum
      4'b0110 : RESULT = A - B;     //sub
      4'b0111 : RESULT = B;         //buff
      4'b1100 : RESULT = ~(A | B);  //nor
    endcase

    if (RESULT == 0) begin
      ZFLAG = 1'b1;
    end else begin
      ZFLAG = 1'b0;
    end
	 
	 if (RESULT < 0) begin
		NFLAG = 1'b1;
	 end else begin
		NFLAG = 1'b0;
	 end
	 
  end
endmodule

module REG
(
  input [3:0] read_addr1,
  input [3:0] read_addr2,
  input [3:0] write_addr,
  input [31:0] write_data,
  input reset,
  input CONTROL_REGWRITE,
  output reg [31:0] data1,
  output reg [31:0] data2
);

  reg [31:0] Data[31:0];
  integer counter;

  always @(read_addr1, read_addr2, write_addr, write_data, CONTROL_REGWRITE, reset) begin
	  if (reset == 1) begin
		  for (counter = 0; counter < 31; counter = counter + 1) begin
			  Data[counter] = counter;
		  end
		  Data[counter] = 32'h0000;
	  end
	  
    data1 = Data[read_addr1];
    data2 = Data[read_addr2];
	 

    if (CONTROL_REGWRITE == 1) begin
      Data[write_addr] = write_data;
    end
  end
endmodule



module DATmem
(
  input [10:0] addr, //possible to reference 2^11 addresses
  input [31:0] in_data,
  input CONTROL_MemRead,
  input CONTROL_MemWrite,
  output reg [31:0] out_data
);

  reg [31:0] Data[31:0]; // Just 32 for faster compilation
  
    always @(addr, in_data, CONTROL_MemRead, CONTROL_MemWrite) begin
      if (CONTROL_MemWrite == 1) begin
        Data[addr] = in_data;
      end

      if (CONTROL_MemRead == 1) begin
        out_data = Data[addr];
      end
    end
endmodule


module INSTmem
(
  input [31:0] INST_ADDR,
  output reg [31:0] CPU_INST
);
  //size        //quantity
  reg [31:0] Data[31:0];

  initial begin
    //MOVI R7, d'15
	 Data[0] = 32'b0010000000000000000111100000111;
	 //MOVI R5, d'3
	 Data[1] = 32'b0010000000000000000001100000101;
	 
	 
	 // STR Rd=R7, into addr[R5]+2   STORE 15 INTO POS 5 IN DATA MEM
	 Data[2] = 32'b00000000001000000000001001010111;
	 //LDR Rd=R3, from addr[3+2] LOAD 15 FROM DATA MEM IN REG
	 Data[3] = 32'b00000000000000000000010100000011;  
	 
  end

  always @(INST_ADDR) begin
    CPU_INST = Data[INST_ADDR];
  end
endmodule