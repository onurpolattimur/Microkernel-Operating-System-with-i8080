#ifndef H_MEMORY
#define H_MEMORY

#include <cstdlib>
#include "memoryBase.h"
#include <fstream>

// This is just a simple memory with no virtual addresses.
// You will write your own memory with base and limit registers.

class Memory: public MemoryBase {
public:
    typedef struct _pageTableEntry{
        int valid;
        int pageFrame;
        int modified;
        int referenced;
    }_pageTableEntry;

    typedef struct _pageTable{
        _pageTableEntry entry[16];
    }_pageTable;

    Memory(uint64_t size);
    ~Memory() {
        systemOutput.close();
        free(realMem);
    }
    virtual uint8_t & at(uint32_t ind);
    virtual uint8_t & physicalAt(uint32_t ind);
    uint16_t getBaseRegister() const { return baseRegister;}
    uint16_t getLimitRegister() const { return limitRegister;}
    void setBaseRegister(uint16_t base) { this->baseRegister = base;}
    void setLimitRegister(uint16_t limit) {this->limitRegister = limit;}
    uint8_t & MemoryManagementUnit(uint32_t, int kernelCall);
    void printPageFault(int currentProcess,uint32_t virtualAddress,uint32_t physicalAddress,int pageToBeReplaced);
    void printPageTables();
    std::ofstream systemOutput;
    int nextPageFrame();
    uint8_t& kernelCall(uint32_t ind);

private:
    uint8_t * realMem;
    uint16_t baseRegister;
    uint16_t limitRegister;
    uint8_t * virtualMemory[4];
    _pageTable pageTables[4];
    int pageFrameIndexes[8]={0,1,2,3,4,5,6,7};
    int currentPageFrame=0;


};

#endif

