
include SLmake.inc

#GNU
SRCS=$(wildcard src/*.f90)
PROGS=$(patsubst src/%.f90,bin/%,$(SRCS))



#INTEL

ifeq ($(TARGET),intel)

	FC=mpiifort
	OPTF    = -O3 -nofor_main -qopenmp -traceback -fPIC 
	FFLAGS  = $(OPTF) -I${MKLROOT}/include/intel64/lp64 -I${MKLROOT}/include -fpp -fPIC

	LAPACK = -L${MKLROOT}/lib/intel64/ -lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core #lmkl_lapack95_lp64 lmkl_sequential.a
	SCALAP = -lmkl_scalapack_lp64 -lmkl_blacs_intelmpi_lp64
	LIBBLAS =-lmkl_blas95_lp64
	LIBPAR = $(LAPACK) $(LIBBLAS) $(SCALAP)

	LIBS=-Wl,--start-group $(LIBPAR) -Wl,--end-group -lpthread -lm -ldl
endif

all: $(PROGS)

bin/%: src/%.f90
	$(FC) $(FFLAGS) -o $@ $< $(LIBS) -g
clean:
	rm -f bin/*
