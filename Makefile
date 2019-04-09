
include SLmake.inc

#GNU
SRCS=$(wildcard src/*.f90)
PROGS=$(patsubst src/%.f90,bin/%,$(SRCS))



#INTEL

ifeq ($(TARGET),intel)

	FC=mpiifort
	FFLAGS=-i8 -I${MKLROOT}/include/intel64/ilp64 -I${MKLROOT}/include -fpp

	LIBS=-L${MKLROOT}/lib/intel64/libmkl_blas95_ilp64.a ${MKLROOT}/lib/intel64/libmkl_lapack95_ilp64.a ${MKLROOT}/lib/intel64/libmkl_scalapack_ilp64.a -Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_intel_ilp64.a ${MKLROOT}/lib/intel64/libmkl_sequential.a ${MKLROOT}/lib/intel64/libmkl_core.a ${MKLROOT}/lib/intel64/libmkl_blacs_intelmpi_ilp64.a -Wl,--end-group -lpthread -lm -ldl
endif

all: $(PROGS)

bin/%: src/%.f90
	$(FC) $(FFLAGS) -o $@ $<  $(SCALAPACKLIB) $(LIBS) -g
clean:
	rm -f bin/*

# Intel: $(PROGS)

# bin/%: src/%.f90
# 	$(FC) $(FFLAGS) -o $@ $< $(LINK)

# clean:
# 	rm -f bin/*

# error:
# 	rm -f errors/*

# output:
# 	rm -f outputs/*