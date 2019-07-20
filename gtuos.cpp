#include <iostream>
#include "8080emuCPP.h"
#include "gtuos.h"
#include "memory.h"

using namespace std;

GTUOS::~GTUOS() {
    if (ofn.is_open()) ofn.close();
    if (ifn.is_open()) ifn.close();

}

GTUOS::GTUOS() {
    usingFiles = false;
    if (!usingFiles) {
        in = &cin;
        out = &cout;
    } else {
        ifn.open("input.txt");
        in = &ifn;

        ofn.open("output.txt", ios::out);
        out = &ofn;
    }
}

/**
 * Handle system call and redirect related function.
 * @param cpu Emulator object.
 * @param DEBUG If debug = 1, you can see detail about system call on console screen
 * @return Now, zero.
 */
uint64_t GTUOS::handleCall(CPU8080 &cpu, int DEBUG) {
    debugMode = DEBUG;
    debugMode = 0;

    uint8_t RegA = cpu.state->a;
    switch (RegA) {
        case PRINT_B_CODE:
            if (DEBUG == 1) *out << "\tSystemcall - PRINT_B" << endl;
            PRINT_B(cpu);
            break;
        case PRINT_MEM_CODE:
            if (DEBUG == 1) *out << "\tSystemcall - PRINT_MEM" << endl;
            PRINT_MEM(cpu);
            break;
        case PRINT_STR_CODE:
            if (DEBUG == 1) *out << "\tSystemcall - PRINT_STR" << endl;
            PRINT_STR(cpu);
            break;
        case READ_B_CODE:
            if (DEBUG == 1) *out << "\tSystemcall - READ_B" << endl;
            READ_B(cpu);
            break;
        case READ_STR_CODE:
            if (DEBUG == 1) *out << "\tSystemcall - READ_STR" << endl;
            READ_STR(cpu);
            break;
        case READ_MEM_CODE:
            if (DEBUG == 1) *out << "\tSystemcall - READ_MEM" << endl;
            READ_MEM(cpu);
            break;
        case LOAD_EXEC_CODE:
            if (DEBUG == 1) *out << "\tSystemcall - LOAD_EXEC" << endl;
            LOAD_EXEC(cpu);
            break;
        case PROCESS_EXIT_CODE:
            if (DEBUG == 1) *out << "\tSystemcall - PROCESS_EXIT" << endl;
            PROCESS_EXIT(cpu);
            break;
        case SET_QUANTUM_CODE:
            if (DEBUG == 1) *out << "\tSystemcall - SET_QUANTUM" << endl;
            SET_QUANTUM(cpu);
            break;
        default:
            if (DEBUG == 1) *out << "Undhandled system call" << endl;
            break;
    }
    return 0;
}

/**
 * Print the content of register b as decimal.
 * @param cpu CPU object from emulator.
 * @return Clock cycle. 10
 */
int GTUOS::PRINT_B(const CPU8080 &cpu) {
    if (debugMode == 1) *out << "\tContent of register B: " << (int) cpu.state->b << endl;
    else *out << (int) cpu.state->b;
    return 10;
}


/**
 * Print integer pointed by BC registers.
 * @param cpu CPU object from emulator.
 * @return  Clock cycle. 10
 */
int GTUOS::PRINT_MEM(const CPU8080 &cpu) {

    uint16_t address = cpu.state->b | cpu.state->c;

    if (debugMode == 1)
        *out << "\tContent of memory address " << address << " : " << (int) (cpu.memory->at(address)) << endl;
    else
        *out << (int) (cpu.memory->at(address));


    return 10;
}


/**
 * Read integer from user. The input should be between 0 and 255.
 * @param cpu CPU emulator object.
 * @return Clock cycle. 10
 */
int GTUOS::READ_B(const CPU8080 &cpu) {
    int decimalNumber;
    bool goodRead = true;
    uint8_t number;


    if (!(*in >> decimalNumber)) goodRead = false;

    if (decimalNumber >= 0 && decimalNumber <= 255 && goodRead) {
        number = (uint8_t) decimalNumber;
        cpu.state->b = number;
    } else {
        *out << "You can enter only decimal numbers between 0-255. Now B=0" << endl;
        cpu.state->b = 0;
    }
    return 10;
}


/**
 * Get integer from user and put it into MEM[BC]
 * This function concatenate B|C automatically, you don't need to do this operation.
 * @param cpu CPU emulator object.
 * @return Clock cycle. 10
 */
int GTUOS::READ_MEM(const CPU8080 &cpu) {
    int decimalNumber;
    uint16_t address = cpu.state->b | cpu.state->c;
    *in >> decimalNumber;

    if (decimalNumber >= 0 && decimalNumber <= 255) {
        cpu.memory->at(address) = (uint8_t) decimalNumber;
    } else {
        *out << "You can enter only decimal numbers between 0-255. Now MEM[BC] = 0" << endl;
        cpu.memory->at(address) = 0;
    }
    return 10;

}

/**
 * Pring string pointed BC registers.
 * @param cpu CPU emulator object.
 * @return Clock cycle. 10 per character.
 */
int GTUOS::PRINT_STR(const CPU8080 &cpu) {
    uint16_t address = (cpu.state->b << 8) | cpu.state->c;
    if (debugMode == 1) *out << "\tString starting from address " << address << endl << "\t";
    uint16_t cycle = 0;
    char readedChar;
    while ((readedChar = cpu.memory->at(address)) != '\0') {
        *out << (readedChar);
        if (readedChar == '\t') address++; //\t bastırdığımız zaman sonrasını null yapıyor. O yüzden adresi 2 arttırdım.
        address++;
        cycle++;
    }
    return cycle * 10;

}


/**
 * Get string from user and put it into MEM[BC].
 * @param cpu CPU emulator object.
 * @return clock cyles. 10 per character.
 */
int GTUOS::READ_STR(const CPU8080 &cpu) {
    uint16_t address = cpu.state->b | cpu.state->c;
    string input;
    *out << "Enter a string: " << std::endl;

    //Sometimes below two lines may be required to clear the buffer.
    std::cin.clear();
    std::cin.sync();

    getline(*in, input);

    uint32_t i;
    for (i = 0; i < input.length(); i++) {
        cpu.memory->at(address + i) = (uint8_t) input[i];
    }
    cpu.memory->at(i + address) = '\0';
    return static_cast<int>(10 * input.length());
}


/**
 * Loads process
 * @param cpu emulator object
 * @return cycle number
 */
int GTUOS::LOAD_EXEC(CPU8080 &cpu) {

    int address = (cpu.state->b << 8) | cpu.state->c;
    char *fileName = (char *) malloc(256);
    uint16_t cycle = 0;
    while ((fileName[cycle] = cpu.memory->at(address + cycle)) != '\0') {
        cycle++;
    }

    int addressHL;
    addressHL = (cpu.state->h << 8) | cpu.state->l;

    cpu.ReadFileIntoMemoryAt(fileName, addressHL);

    return CYCLE_PER_CALL * 10;
}

/**
 * Sets quantum. 
 * @param cpu emulator object
 * @return cycle number
 */
int GTUOS::SET_QUANTUM(CPU8080 &cpu) {

    cpu.setQuantum(cpu.state->b);
    return 7;

}

/**
 * Exits process. 
 * @param cpu emulator object
 * @return cycle number
 */
int GTUOS::PROCESS_EXIT(CPU8080 &cpu) {


    Memory *mem = (Memory *) cpu.memory;
    uint8_t pid = 0;
    pid = mem->kernelCall(0x0d0a);
    int changed = 0;
    for (int i = 0; i < 10; i++) {
        uint32_t a = static_cast<uint32_t>((i + 2) * 256 + 2);
        if (mem->kernelCall(a) == pid && mem->kernelCall(a) != 0) {
            if (mem->kernelCall((pid + 2) * 256 + 2) == i) {
                changed = 0;
                break;
            } else {
                mem->kernelCall(a) = mem->kernelCall((pid + 2) * 256 + 2);
                changed = 1;
                break;
            }
        }
    }

    if (changed == 0) {
        mem->kernelCall(0x0d00) = 1;
    }


    return CYCLE_PER_CALL * 8;
}