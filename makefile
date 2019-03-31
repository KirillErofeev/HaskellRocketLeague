GHC_INCLUDE = /usr/lib/ghc/include

#test: clean main; ./codeball2018-linux/codeball2018 --p1 tcp-31003 --p1-dump ../out --no-countdown --noshow --log-file ../log --results-file ../r --duration 601 & (sleep 1 && ./a.out)

test: clean main; ./codeball2018-linux/codeball2018 --p1 tcp-31003 --p2 helper --p1-dump ../out --no-countdown --log-file ../log --results-file ../r --duration 1801 & (sleep 1 && ./a.out)

all: main;

main: HaskellRL.o main.o; \
    ghc -o a.out -no-hs-main *.o -lstdc++

main.o: Runner.cpp; g++ -std=c++11 -c *.cpp csimplesocket/*.cpp -I$(GHC_INCLUDE)

HaskellRL.o: HaskellRL.hs; ghc -fforce-recomp HaskellRL.hs

.PHONY: clean
clean: ; rm -rf *.o a.out *_stub.h *.hi
