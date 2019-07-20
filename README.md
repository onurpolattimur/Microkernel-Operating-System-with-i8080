
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
 > **Note:** If you are to write new ASM files, you must use PROCESS_EXIT syscall, HLT instruction is used to halt emulator. 

<p align="center"><img src="https://consequenceofsound.net/wp-content/uploads/2017/04/screen-shot-2017-04-01-at-7-47-18-pm.jpg?quality=80" width="300px"/></p>

## Workflow

- Kernel loads a process into specific memory location. The memory location of each process is shown in the excel file “**Memory Management.xsl**”. In order to do so it uses a system call which is written in C++.

- The kernel keeps all the necessary information of a process in the Process Table.

- The emulator generates interrupts which kernel handles properly. In the case of an interrupt the kernel traps the interrupt and performs a context switching.

- In context switching the kernel saves the current state of a process, stops executing it and selects an appropriate process from the memory using Round Robin Scheduling.

- Whenever a context switching occurs the information of current process is shown to user using process table.
***

-In the this version of kernel there are 3 different processes loaded in the memory and executed properly. The programs loaded are Sum.asm, Primes.asm and Collatz.asm. Each program has its own memory location assigned to it. The details of the memory allocation can be found in the Excel file provided.

## Virtual Memory and Paging
The memory management unit supports page faults and performs page replacement algorithms. 
The properties of MMU:
 - Your computer has 8 KBytes of physical main memory 
 - Each process has a virtual address space of 16 KBytes.  Therefore, even if you there is one process running, you will need many page replacements because your physical memory is not large enough to hold one process.
 -  If an instruction does not find its operand in memory or it is not in memory, it causes a page fault 
 -  The programs  use virtual addresses, so each address is translated 
***
The paging system will have the following features
 -  The page size is 1 KBytes 
 - The page table holds the following information for each page
	 ◦ Modified bit 
	 ◦ Referenced bit
	 ◦ Present/absent
	 ◦ Page frame number 
	 ◦ Any other information needed by your system
 - The FIFO method is used as page replacement algoritm. This algorithm is not very efficient but it is easy to implement. 

## About Assembly Files

- Sum.asm : It sums up the numbers from 1 to 20. 
- Collatz.asm: It finds collatz sequence of each number less then 25. 
	A Collatz sequence is a sequenceformed by iteratively applying the function defined for the Collatz problem to a given starting integer n, in which if 2|n , <img src="https://raw.githubusercontent.com/onurpolattimur/Microkernel-Operating-System-with-i8080/master/SS/ndivtwo.png?token=AFQQRNOB4SVBS7LBQM3OQUC5GM24S"/> and if not then <img src="https://raw.githubusercontent.com/onurpolattimur/Microkernel-Operating-System-with-i8080/master/SS/gif.latex.gif?token=AFQQRNNGN2Q63LDHNDOAPVK5GM2RQ"/>.<br>
	`Example for 7:  22 11 34 17 52 26 13 40 20 10 5 16 8 4 2 1`
- Primes.asm: It finds prime numbers in range of 1-1000. 
In order to do this you have to use some tricks siince the i8080 processor is 8bits. We cannot represent numbers grater then 255 in i8080 architecure. The PRINT_B syscall writes the content of register B, the register B is 8 bits.  So the number to be printed has been divided to two pieces. There are detailed explanations in Primes.asm file.  But I want to show you the preview here.
```sh
Print 16 bit decimal number to screen.
This procedure can print only numbers between 0-2600.
I print the number in two parts.
    1516|_10_
    -___| 151
       6
First print quatient and then print remainder.
```
	

## USAGE

  > **Note:** There is makefile provided.  
```sh
$ ./GTUOS MicroKernel1.com 0
```
By default, the output goes to screen, if you want to write outputs to file you need make true usingFiles variable in gtuos.cpp.
```sh
usingFiles = true;
```
0 or 1 indicates the DEBUG mode. In 0 DEBUG mode is off.

In debug mode, you can see all the content of registers on every instruction executed.
<p align="center">
<img src="https://raw.githubusercontent.com/onurpolattimur/Microkernel-Operating-System-with-i8080/master/SS/terminal_1.png?token=AFQQRNJM7ER53S6QMVOWGYS5GMWB6"/></p>

## How to compile Assembly files

The assembly files can be converted to .com by using http://sensi.org/~svo/i8080. All that has to be done is to copy the code and paste it into the given link and save it by clicking “Make Beautiful Code”.

