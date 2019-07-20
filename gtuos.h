#ifndef H_GTUOS
#define H_GTUOS

#include "8080emuCPP.h"
#include <fstream>

#define PRINT_B_CODE     4
#define PRINT_MEM_CODE   3
#define READ_B_CODE      7
#define READ_MEM_CODE    2
#define PRINT_STR_CODE   1
#define READ_STR_CODE    8
#define LOAD_EXEC_CODE    5
#define PROCESS_EXIT_CODE    9
#define SET_QUANTUM_CODE    6
#define CYCLE_PER_CALL 10
class GTUOS {
public:
	GTUOS();

	~GTUOS();

	uint64_t handleCall(CPU8080 &cpu, int DEBUG);

	int PRINT_B(const CPU8080 &cpu);

	int PRINT_MEM(const CPU8080 &cpu);

	int PRINT_STR(const CPU8080 &cpu);

	int READ_B(const CPU8080 &cpu);

	int READ_STR(const CPU8080 &cpu);

	int READ_MEM(const CPU8080 &cpu);

	int LOAD_EXEC(CPU8080 &cpu);

	int PROCESS_EXIT(CPU8080 &cpu);

	int SET_QUANTUM(CPU8080 &cpu);


private:
	int debugMode;
	bool usingFiles;
	std::istream *in;
	std::ostream *out;

	std::ifstream ifn;
	std::ofstream ofn;
};

#endif
