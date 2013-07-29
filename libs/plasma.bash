add_package \
    http://icl.cs.utk.edu/projectsfiles/plasma/pubs/plasma_2.5.1.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libplasma.a

pack_set --module-requirement hwloc

if $(is_c gnu) ; then
    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --module-requirement atlas
    else
	pack_set --module-requirement blas
    fi
fi

# We only require this due to the LAPACKE library
pack_set --module-requirement lapack

tmp=make.inc
pack_set --command "echo '# Makefile for easy installation ' > $tmp"

# We will create our own makefile from scratch (the included ones are ****)
if $(is_c gnu) ; then
    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --command "sed -i '1 a\
LIBBLAS  = $(list --LDFLAGS --Wlrpath atlas) -lf77blas -latlas \n\
LIBCBLAS = $(list --LDFLAGS --Wlrpath atlas) -lcblas \n' $tmp"
    else
	pack_set --command "sed -i '1 a\
LIBBLAS  = $(list --LDFLAGS --Wlrpath blas) -lblas \n\
LIBCBLAS = $(list --LDFLAGS --Wlrpath blas) -lcblas \n' $tmp"
    fi
    pack_set --command "sed -i '1 a\
LIBLAPACK = $(list --LDFLAGS --Wlrpath lapack) -llapack\n' $tmp"

elif $(is_c intel) ; then
    pack_set --command "sed -i '1 a\
CFLAGS  += -DPLASMA_WITH_MKL -openmp \n\
FFLAGS  += -fltconsistency -fp-port \n\
LDFLAGS += -nofor-main \n\
LIBBLAS  = $MKL_LIB -lmkl_blas95_lp64 -mkl=parallel \n\
LIBCBLAS  = $MKL_LIB -lmkl_blas95_lp64 -mkl=parallel \n\
LIBLAPACK = $MKL_LIB -lmkl_lapack95_lp64 -mkl=parallel \n' $tmp"
fi

pack_set --command "sed -i '1 a\
INCCLAPACK = $(list --INCDIRS lapack)\n\
LIBCLAPACK = $(list --LDFLAGS --Wlrpath lapack) -llapacke\n' $tmp"

pack_set --command "sed -i '1 a\
PLASMA_F90 =1\n\
prefix = $(pack_get --install-prefix)\n\
CC = $CC -DADD_ \n\
FC = $FC \n\
LOADER = \$(FC) \n\
ARCH = $AR \n\
ARCHFLAGS = cr \n\
RANLIB = ranlib \n\
\n\
CFLAGS = $CFLAGS -DADD_\n\
FFLAGS = $FFLAGS \n\
LDFLAGS = $FFLAGS \n' $tmp"

# Make and install commands
pack_set --command "make $(get_make_parallel) all"
pack_set --command "make install"