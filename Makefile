# Change the next line to your local runner's working directory
# or pass it via an environment variable
LOCAL_RUNNER_HOME ?= /some/path/local-runner-ru
DC ?= dmd
DFLAGS ?= -O -release -inline -boundscheck=off -wi
DDEBUGFLAGS ?= -g -debug -debug=io -unittest -wi
LOCAL_RUNNER ?= ./local-runner.sh

SRC=$(wildcard *.d) $(wildcard model/*.d)

all : MyStrategy

MyStrategy : $(SRC)
	$(DC) $(DFLAGS) $(SRC) -of$@

debug : $(SRC)
	$(DC) $(DDEBUGFLAGS) $(SRC) -ofMyStrategy

run : MyStrategy
	cd $(LOCAL_RUNNER_HOME) && $(LOCAL_RUNNER)
	sleep 2
	./MyStrategy

clean :
	$(RM) MyStrategy MyStrategy.exe *.o *.obj compilation.log result.txt
