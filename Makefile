
include SLmake.inc

EXE_NAME=inverse
# EXE_CPP=
OBJ_EXEC=$(patsubst %.cpp,%.o, $(EXE_NAME)/*.cpp)

#GNU
SRCS 	=$(wildcard fortran/*.f90)
COMMONF =modules/
MOD 	=$(wildcard $(COMMONF)*.f90)
MOD_C	=$(subst $(COMMONF),,$(MOD))
OBJ_MOD0=$(patsubst %.f90,%.o, $(MOD_C) )
OBJ_MOD =$(addprefix obj/, $(OBJ_MOD0))
PROGS 	=$(patsubst fortran/%.f90,bin/%,$(SRCS))

SRCS_CPP=$(wildcard $(EXE_NAME)/*.cpp)

COMMON=common/
COMMON_CPP=$(subst $(COMMON),,$(wildcard $(COMMON)*.cpp))
# FILES=$(patsubst %.cpp,%.o, $(wildcard ../common/*.cpp)) #blacs_grid block_cyclic_mat fortran_runtime inverse#$(wildcard ../common/*.cpp)
OBJECTS=$(patsubst %.cpp,%.o, $(COMMON_CPP))#$(addsuffix .o, $(FILES))

CPPFLAGS=-I$(COMMON)
BIN=bin/$(EXE_NAME)

#INTEL

ifeq ($(TARGET),intel)

	FC=mpiifort
	CXX=mpiicpc -std=c++11
	OPTF    = -O3 -nofor_main -qopenmp -traceback -fPIC 
	FFLAGS  = $(OPTF) -I${MKLROOT}/include/intel64/lp64 -I${MKLROOT}/include -fpp -fPIC
	CCFLAGS = -O3 -qopenmp -traceback -fPIC -I${MKLROOT}/include/intel64/lp64 -I${MKLROOT}/include
	
	LIBBLAS = -lmkl_blas95_lp64
	LAPACK 	= -lmkl_lapack95_lp64
	SCALAP 	= -lmkl_scalapack_lp64 -Wl,--start-group -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lmkl_blacs_intelmpi_lp64
	LIBPAR 	= -L${MKLROOT}/lib/intel64/ $(LIBBLAS) $(LAPACK) $(SCALAP)

	LIBS 	= $(LIBPAR) -Wl,--end-group -lpthread -lm -ldl
	LIBSF	= $(LIBS)
endif

default:$(OBJ_MOD) $(PROGS)

bin:
	mkdir -p bin

obj:
	mkdir -p obj

.PHONY: default cpp all dir clean

cpp: $(BIN)

all: default cpp

bin/%: fortran/%.f90 | bin
	$(FC) $(FFLAGS) -o $@ $^ $(OBJ_MOD) $(LIBSF) -g

obj/%.o: $(COMMONF)%.f90 | obj
	$(FC) $(FFLAGS) -c -o $@ $^ -g

$(BIN):$(addprefix obj/, $(OBJECTS))| bin
	$(CXX) $(CCFLAGS) $(CPPFLAGS) -o $@ $(SRCS_CPP) $^ $(LIBS) -g

obj/%.o: $(COMMON)%.cpp | obj
	$(CXX) $(CCFLAGS) -c -o $@ $^ -g

clean:
	rm -f bin/* obj/* *.mod out_*