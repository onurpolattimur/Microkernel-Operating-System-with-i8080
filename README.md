
# Operating System Kernel written in Assembly

An operating system Kernel written in Intel i8080 assembly language.

It supports multi programming, interrupt handling and memory management.

You can find the detailed explanation of the kernel and the emulator needed to use the kernel below.

## i8080 Emulator

The emulator which is written in C++ can be found online. It provides a set of instructions supported by i8080 which can be found  <a href="http://www.emulator101.com/reference/8080-by-opcode.html">here.</a>




## Supported System Calls
 `The system calls are implemented in C++. You can find details about these calls in gtuos.cpp.`
 
 | Syscall        | Code| Details|
| ------------- |:-------------:| :-----------|
| **PRINT_B**      | 0x04 | Prints the contents of Register B as decimal. |
| **READ_B**      | 0x07|   Reads an integer from the keyboard and stores it in Register B. |
| **PRINT_MEM** | 0x03      |   Prints the contents of memory pointed by B and C as decimal. |
| **READ_MEM** | 0x02 | Reads an integer from the keyboard and stores it into address Register BC.|
| **PRINT_STR** | 0x01 | Prints the null terminated string at the address pointed by registers B and C.|
| **READ_STR** | 0x08 | Reads the null terminated string from the keyboard and stores it in memory location pointer by registers B and C.|
| **LOAD_EXEC** | 0x05 | It loads the program specified in the filename starting from the start address.|
| **PROCESS_EXIT** | 0x09 | Causes operating system to clear and update the resources of the finished process and return control to the scheduler.|
|  **SET_QUANTUM** | 0x06 | It changes the QUANTUM_TIME of the Round Robin Scheduler. | 

## The General Idea

The main idea is to load and execute programs/processes, handle interrupts properly and perform context switching using Round Robin Scheduling. 

 `** If you are to write new ASM files, you must use PROCESS_EXIT syscall, HLT instruction is used to halt emulator. `
<p align="center"><img src="https://consequenceofsound.net/wp-content/uploads/2017/04/screen-shot-2017-04-01-at-7-47-18-pm.jpg?quality=80" width="500px"/></p>

## Workflow

- Kernel loads a process into specific memory location. The memory location of each process is shown in the excel file “Memory Management.xsl”. In order to do so it uses a system call which is written in C++.

- The kernel keeps all the necessary information of a process in the Process Table.

- The emulator generates interrupts which kernel handles properly. In the case of an interrupt the kernel traps the interrupt and performs a context switching.

- In context switching the kernel saves the current state of a process, stops executing it and selects an appropriate process from the memory using Round Robin Scheduling.

- Whenever a context switching occurs the information of current process is shown to user using process table.

There are 3 versions of kernel implemented.

**MicroKernel1:** In the first version of the kernel there are 3 different processes loaded in the memory and executed properly. The programs loaded are Sum.asm, Primes.asm and Collatz.asm. Each program has its own memory location assigned to it. The details of the memory allocation can be found in the Excel file provided.

**MicroKernel2:** In the second version of the kernel a program is chosen randomly and loaded into memory 10 times. In other words, same program 10 different processes.

**MicroKernel3:** In the third and last version of the kernel 2 programs are chosen and loaded 3 times.

## USAGE

There is makefile provided.

./GTUOS MicroKernel1.com 0

./GTUOS MicroKernel2.com 0

./GTUOS MicroKernel3.com 1

0 or 1 indicates the DEBUG mode. In 0 DEBUG mode is off.

The output is written into output.txt file.

## How to compile Assembly files

The assembly files can be converted to .com by using http://sensi.org/~svo/i8080. All that has to be done is to copy the code and paste it into the given link and save it by clicking “Make Beautiful Code”.
