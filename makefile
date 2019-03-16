GHC_INCLUDE = /usr/lib/ghc/include

all: main;

main: HaskellRL.o main.o; \
    ghc -o a.out -no-hs-main *.o -lstdc++

main.o: Runner.cpp; g++ -std=c++11 -c *.cpp csimplesocket/*.cpp -I$(GHC_INCLUDE)

HaskellRL.o: HaskellRL.hs; ghc -fforce-recomp HaskellRL.hs

.PHONY: clean
clean: ; rm -rf *.o a.out *_stub.h *.hi
