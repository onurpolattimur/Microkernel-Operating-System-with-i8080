#include <iostream>
#include <cstring>
#include <fstream>
#include "memory.h"

Memory::Memory(uint64_t size) {
    realMem = (uint8_t *) calloc(8192, sizeof(uint8_t));
    virtualMemory[0] = (uint8_t *) calloc(0x4000, sizeof(uint8_t));
    virtualMemory[1] = (uint8_t *) calloc(0x4000, sizeof(uint8_t));
    virtualMemory[2] = (uint8_t *) calloc(0x4000, sizeof(uint8_t));
    virtualMemory[3] = (uint8_t *) calloc(0x4000, sizeof(uint8_t));
    baseRegister = 0;
    limitRegister = 0;

    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 16; j++) {
            pageTables[i].entry[j].valid = 0;
            pageTables[i].entry[j].pageFrame = 0;
            pageTables[i].entry[j].referenced = 0;
            pageTables[i].entry[j].modified = 0;
        }
    }
    systemOutput.open("system.txt", std::ios::out);

    std::ofstream pageoutput;
    pageoutput.open("pagetable.txt", std::ios::out |std::ios::trunc);
    pageoutput.close();

}

uint8_t &Memory::at(uint32_t ind) {
    return MemoryManagementUnit(ind, 0);
}

uint8_t &Memory::MemoryManagementUnit(uint32_t address, int kernelCall) {
    int pTable = 0;
    if (kernelCall == 1) {
        pTable = 0;
    } else if (baseRegister == 0x0000) {
        pTable = 0;
    } else if (baseRegister == 0x4000) {
        pTable = 1;
    } else if (baseRegister == 0x8000) {
        pTable = 2;
    } else if (baseRegister == 0xc000) {
        pTable = 3;
    }
    _pageTable *pageTable = &(pageTables[pTable]);
    int pageTableIndex = address / 1024;
    int offset = (address % 1024);
    int pageFrame = pageTable->entry[pageTableIndex].pageFrame;

    if (pageTable->entry[pageTableIndex].valid == 0) {
        pageFrame =nextPageFrame();
        printPageFault(pTable, address, static_cast<uint32_t>((pageFrame * 1024) + offset), pageFrame);
        for (int k = 0; k < 16; k++) {
            for (int i = 0; i < 4; i++) {
                if (this->pageTables[i].entry[k].valid == 1 &&
                    this->pageTables[i].entry[k].pageFrame == pageFrame) {
                    for (int j = 0; j < 1024; j++) {
                        virtualMemory[i][(k * 1024) + j] = realMem[(pageFrame * 1024) + j];
                    }
                    this->pageTables[i].entry[k].valid = 0;
                    this->pageTables[i].entry[k].modified = 1;
                    break;
                }
            }
        }
        for (int i = 0; i < 1024; i++) {
            realMem[(pageFrame * 1024) + i] = virtualMemory[pTable][(pageTableIndex * 1024) + i];
            pageTable->entry[pageTableIndex].referenced = 0;
            pageTable->entry[pageTableIndex].modified = 0;
        }
        this->pageTables[pTable].entry[pageTableIndex].valid=1;
        pageTable->entry[pageTableIndex].pageFrame = pageFrame;
        printPageTables();
    } else pageTable->entry[pageTableIndex].referenced = 1;

    return realMem[(pageFrame * 1024) + offset];

}

void Memory::printPageFault(int currentProcess,uint32_t virtualAddress, uint32_t physicalAddress, int pageToBeReplaced) {
    char outTex[256];
    std::sprintf(outTex, "PAGEFAULT: %d,%04x,%04x,%d", currentProcess, virtualAddress, physicalAddress, pageToBeReplaced);
    systemOutput << outTex << std::endl;
}

void Memory::printPageTables() {
    std::ofstream pageOutput;
    pageOutput.open("pagetable.txt",std::ios::out | std::ios::app);
    for (int i = 0; i < 4; i++) {
        pageOutput << "Page Table " << i << ":" << std::endl;
        for (int j = 0; j < 16; j++) {
            pageOutput << "Index: " << j;
            pageOutput << " Valid Bit: " << pageTables[i].entry[j].valid;
            pageOutput << " Frame: " << pageTables[i].entry[j].pageFrame;
            pageOutput << " Referenced Bit: " << pageTables[i].entry[j].referenced;
            pageOutput << " Modified Bit: " << pageTables[i].entry[j].modified;
            pageOutput << std::endl;
        }
    }
    pageOutput.close();
}


uint8_t &Memory::physicalAt(uint32_t ind) {
    int virtualMemInd = 0;
    uint32_t index = ind;
    if (ind == 0x0000) virtualMemInd = 0;
    else if (ind == 0x4000) {
        virtualMemInd = 1;
        index = index - 0x4000;
    } else if (ind == 0x8000) {
        virtualMemInd = 2;
        index = index - 0x8000;
    } else if (ind == 0xc000) {
        virtualMemInd = 3;
        index = index - 0xc000;
    }else{
        return kernelCall(ind);
    }
    return virtualMemory[virtualMemInd][index];
}

int Memory::nextPageFrame() {
    int index = pageFrameIndexes[currentPageFrame];
    currentPageFrame++;
    currentPageFrame = currentPageFrame % 8;
    return index;
}

uint8_t &Memory::kernelCall(uint32_t ind) {
    std::string processName[4]={"Init","Sum","Sort","Prime"};
   if(ind ==256){
        int current = kernelCall(0x0d0a);
        int next = kernelCall(static_cast<uint32_t>(((current + 2) * 256) + 2));
        systemOutput << "CSEVENT: " << current << ", " << processName[current] << "," << next << ","
                       << processName[next] << std::endl;
    }
    return MemoryManagementUnit(ind, 1);
}




