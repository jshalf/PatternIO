#GNU makefile
# USE gmake IF IT DOESNT WORK CORRECTLY ON YOUR SYSTEM!
# This makefile uses gnumake specific conditional syntax
# just comment out the conditional stuff if you can't find gmake

#----------------------------------------------------------------------
# Figure out what kind of system we are on without resorting to config.sub
APRUN := $(shell which aprun)
ifeq ($(APRUN), /usr/bin/aprun)
UNAME = CrayXT
else
UNAME := $(shell uname | perl -pe 's/(sn\d\d\d\d|jsimpson)/UNICOS\/mk/')
endif
#----------------------------------------------------------------------
# now apply correct compilers and build flags for systems we know about
ifeq ($(UNAME), Darwin)
CXX = g++
FLAGS = -O2
MPILIB = -lmpi
endif

ifeq ($(UNAME), AIX)
CXX=mpCC_r
FLAGS = -qhot 
# optional if you want to use GPFS-specific MPI-IO hints
# FLAGS = -qhot -DHAS_GPFS
endif

ifeq ($(UNAME), CrayXT)
CXX = CC 
LUSTREHOME = /opt
# optional if you want to have benchmark automatically manipulate striping
# rather than using the defaults of the directory
# FLAGS = -O2 -DHAS_LUSTRE -I$(LUSTREHOME)/include
# MPILIB = -L$(LUSTREHOME)/lib -llustre_user
FLAGS = -O2
endif

ifeq ($(UNAME), Linux)
CXX = mpicxx
FLAGS = -O2
# FLAGS = -O2 -DHAS_GPFS
endif


all: PatternIO

test:
	echo $(APRUN)
	echo $(UNAME)

Bench: Bench.c
	$(CXX) -DDISABLE_H5PART $(FLAGS) Bench.c -o Bench $(MPILIB) -lm

PatternIO: MPIutils.o Timer.o Timeval.o PatternIO.o
	$(CXX) $(FLAGS) -o PatternIO PatternIO.o Timer.o Timeval.o MPIutils.o $(MPILIB) -lm

MPIutils.o: MPIutils.cc MPIutils.hh
	$(CXX) -c $(FLAGS) MPIutils.cc

Timer.o: Timer.cc Timer.hh Timeval.hh
	$(CXX) -c $(FLAGS) Timer.cc

Timeval.o: Timeval.cc Timeval.hh
	$(CXX) -c $(FLAGS) Timeval.cc

PatternIO.o: PatternIO.cxx Timeval.hh Timer.hh MPIutils.hh
	$(CXX) -c $(FLAGS) PatternIO.cxx

clean: 
	rm -f *.o

distclean: clean
	rm -f PatternIO

