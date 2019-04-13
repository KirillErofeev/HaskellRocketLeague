GHC_INCLUDE=/usr/lib/ghc/include
ifeq ($(CXX),g++)
    GHC_INCLUDE = /usr/lib/ghc/include
endif
ifeq ($(CXX),clang)
    GHC_INCLUDE = /usr/local/Cellar/ghc/8.6.4/lib/ghc-8.6.4/include
endif

#test: clean main; ./codeball2018-linux/codeball2018 --p1 tcp-31003 --p1-dump ../out --no-countdown --noshow --log-file ../log --results-file ../r --duration 601 & (sleep 1 && ./a.out)

rebuild: clean all;

codeball: ; ./codeball2018/codeball2018 --p1 tcp-31003 --p2 helper & (sleep 1 && ./a.out)
codeballEmpty: ; ./codeball2018/codeball2018 --p1 tcp-31003 --p2 empty & (sleep 1 && ./a.out)
codeballEmptyNS: ; ./codeball2018/codeball2018 --noshow --duration 10 --p1 tcp-31003 --p2 empty & (sleep 1 && ./a.out)

testTime: ; ./codeball2018/codeball2018 --noshow --duration 18000 --p1 tcp-31003 --p2 empty & (sleep 1 && ./a.out)

test: clean all; ./codeball2018/codeball2018 --p1 tcp-31003 --p2 helper & (sleep 1 && ./a.out)

testEmpty: clean all; ./codeball2018/codeball2018 --p1 tcp-31003 --p2 empty --p1-dump ../out --no-countdown --log-file ../log --results-file ../r --duration 999 & (sleep 1 && ./a.out)

testEmptyNS: clean all; ./codeball2018/codeball2018 --noshow --p1 tcp-31003 --p2 empty --p1-dump ../out --no-countdown --log-file ../log --results-file ../r --duration 1777 & (sleep 1 && ./a.out)
testEmptyFull: clean all; ./codeball2018/codeball2018 --p1 tcp-31003 --p2 empty --p1-dump ../out --no-countdown --log-file ../log --results-file ../r & (sleep 1 && ./a.out)

testVsKey: clean all; ./codeball2018/codeball2018 --p1 tcp-31003 --p2 keyboard --p1-dump ../out --no-countdown --log-file ../log --results-file ../r --duration 1801 & (sleep 1 && ./a.out)

testAgainstEmptyNoShow: clean all; ./codeball2018/codeball2018 --p1 tcp-31003 --p2 empty --p1-dump ../out --no-countdown --log-file ../log --results-file ../r --noshow --duration 1801 & (sleep 1 && ./a.out)

testNoShow: clean all; ./codeball2018/codeball2018 --p1 tcp-31003 --p2 helper --p1-dump ../out --no-countdown --log-file ../log --results-file ../r --noshow --duration 3000 & ((sleep 1 && (./a.out)) )

testNoShowEmpty: clean all; ./codeball2018/codeball2018 --p1 tcp-31003 --p2 empty --p1-dump ../out --no-countdown --log-file ../log --results-file ../r --noshow --duration 3000 & ((sleep 1 && (./a.out)) )

run: clean all; ./a.out

all: Haskell.o Runner.o; \
    ghc -O2 -o a.out -no-hs-main *.o -lstdc++

Runner.o: Runner.cpp; g++ -O3 -std=c++11 -c *.cpp csimplesocket/*.cpp -I$(GHC_INCLUDE)

Haskell.o: HaskellRL.hs; ghc -O2 -fforce-recomp HaskellRL.hs

.PHONY: clean
clean: ; rm -rf *.o a.out *_stub.h *.hi
