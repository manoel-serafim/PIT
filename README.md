# PIT
CPU desenvolvida em verilog e compilada para rodar em um FPGA altera. 

## Datapath

The PIT CPU features a customized datapath designed to provide modularity for the addition of components within the CPU. This modular approach allows for easy integration of new functionalities and components, enhancing the flexibility and scalability of the CPU design.

## Getting Started

To get started with the PIT CPU, follow these steps:

1. Clone the repository:
```
git clone https://github.com/your-username/pit-cpu.git
```

2. Ensure you have the necessary software and tools installed, including the Verilog compiler and the Altera FPGA development environment.

3. Connect the Altera FPGA to your computer and configure it to run the PIT CPU design.

4. Compile the Verilog code using the appropriate compiler command. For example:
```
verilog -c pit-cpu.v
```

5. Once the compilation is successful, load the compiled code onto the FPGA.

6. The PIT CPU is now ready to be used. Connect peripherals and execute instructions on the CPU as desired.


## Instructions
The PIT CPU supports the following basic assembly commands and more:

Load and Store:

LW (Load Word): Load a word from memory into a register.
SW (Store Word): Store a word from a register into memory.
Arithmetic and Logic:

ADD (Add): Add two registers and store the result in a destination register.
SUB (Subtract): Subtract two registers and store the result in a destination register.
AND (Logical AND): Perform a bitwise AND operation between two registers and store the result in a destination register.
OR (Logical OR): Perform a bitwise OR operation between two registers and store the result in a destination register.
Control Flow:

JUMP (Jump): Unconditionally jump to a specified memory address.
BEQ (Branch if Equal): Branch to a specified memory address if two registers are equal.
BNE (Branch if Not Equal): Branch to a specified memory address if two registers are not equal.
Input and Output:

IN (Input): Read input data from a specified input device into a register.
OUT (Output): Write the contents of a register to a specified output device.
These are just a few examples of the basic assembly commands supported by the PIT CPU. Additional commands and instructions can be added to extend the functionality of the CPU as per specific requirements.

## Simple OPM diagram
![image](https://github.com/manoel-serafim/PIT/assets/57204406/56d37aa6-40ef-45bd-87aa-5e9bb4d73e4c)


## License

The PIT CPU project is licensed under the [MIT License](LICENSE). Feel free to modify and distribute the code according to the terms of the license.

