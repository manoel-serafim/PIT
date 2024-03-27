# PIT
CPU desenvolvida em verilog e compilada para rodar em um FPGA altera. 

## Datapath

The PIT CPU features a customized datapath designed to provide modularity for the addition of components within the CPU. This modular approach allows for easy integration of new functionalities and components, enhancing the flexibility and scalability of the CPU design.

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

