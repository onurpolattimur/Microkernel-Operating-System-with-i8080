
all: compile

compile: 8080emu.o gtuos.o main.o memory.o
	g++ 8080emu.o  gtuos.o main.o memory.o -o GTUOS

main.o: main.cpp
	g++ -g -c -std=c++11 main.cpp

8080emu.o: 8080emu.cpp
	g++ -g -c -std=c++11 8080emu.cpp

gtuos.o: gtuos.cpp
	g++ -g -c -std=c++11 gtuos.cpp

memory.o: memory.cpp
	g++ -g -c -std=c++11 memory.cpp
clean:
	rm *.o GTUOS