add_package \
    http://icl.cs.utk.edu/projectsfiles/plasma/pubs/plasma_2.6.0.tar.gz

pack_set -s $IS_MODULE -s $MAKE_PARALLEL 

pack_set --install-query $(pack_get --install-prefix)/lib/libplasma.a

pack_set --module-requirement hwloc

tmp=make.inc
pack_set --command "echo '# Makefile for easy installation ' > $tmp"

if test -z "$FLAG_OMP" ; then
    doerr PLASMA "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi

# We will create our own makefile from scratch (the included ones are ****)
if $(is_c intel) ; then
    # The tmg-lib must be included...
    pack_set --command "sed -i '1 a\
CFLAGS  += -DPLASMA_WITH_MKL -I$MKL_PATH/include \n\
FFLAGS  += -fltconsistency -fp-port \n\
LDFLAGS += -nofor-main \n\
# We need the C-interface for LAPACK\n\
INCCLAPACK = $(list --INCDIRS blas)\n\
LIBCLAPACK = $(list --LDFLAGS --Wlrpath blas) -llapacke \n\
LIBBLAS  = $MKL_LIB -lmkl_blas95_lp64 -mkl=parallel \n\
LIBCBLAS  = $MKL_LIB -lmkl_blas95_lp64 -mkl=parallel \n\
LIBLAPACK = $MKL_LIB -lmkl_lapack95_lp64 -mkl=parallel \n' $tmp"

else 

    if [ $(pack_installed atlas) -eq 1 ]; then
	bl=atlas
	pack_set --module-requirement atlas
	pack_set --command "sed -i '1 a\
LIBBLAS  = $(list --LDFLAGS --Wlrpath atlas) -lf77blas -latlas \n\
LIBCBLAS  = -lcblas \n' $tmp"
    
    elif [ $(pack_installed openblas) -eq 1 ]; then
	bl=openblas
	pack_set --module-requirement openblas
	pack_set --command "sed -i '1 a\
LIBBLAS  = $(list --LDFLAGS --Wlrpath openblas) -lopenblas \n\
LIBCBLAS  = \n' $tmp"

    else
	bl=blas
	pack_set --module-requirement blas
	pack_set --command "sed -i '1 a\
LIBBLAS  = $(list --LDFLAGS --Wlrpath blas) -lblas \n\
LIBCBLAS  = $(list --LDFLAGS --Wlrpath blas) -lcblas \n' $tmp"

    fi

    pack_set --command "sed -i '1 a\
INCCLAPACK = $(list --INCDIRS $bl)\n\
LIBCLAPACK = $(list --LDFLAGS --Wlrpath $bl) -llapacke \n\
LIBLAPACK  = $(list --LDFLAGS --Wlrpath $bl) -ltmg -llapack\n' $tmp"

fi

pack_set --command "sed -i '1 a\
PLASMA_F90 =1\n\
prefix = $(pack_get --install-prefix)\n\
CC = $CC \n\
FC = $FC \n\
LOADER = \$(FC) \n\
ARCH = $AR \n\
ARCHFLAGS = cr \n\
RANLIB = ranlib \n\
CFLAGS = $CFLAGS $FLAG_OMP -DADD_\n\
FFLAGS = ${FFLAGS//-fp-model strict/} $FLAG_OMP \n\
LDFLAGS = \$(FFLAGS) $(list --LDFLAGS --Wlrpath $(pack_get --module-requirement hwloc) hwloc)\n' $tmp"

# Make and install commands
pack_set --command "make $(get_make_parallel) all"
pack_set --command "make test > tmp.test 2>&1"
pack_set --command "cd testing"
pack_set --command "make all"
pack_set --command "python plasma_testing.py -c 2 >> ../tmp.test 2>&1"
pack_set --command "cat testing_results.txt >> ../tmp.test"
pack_set --command "cd .."
pack_set --command "make install"
pack_set_mv_test tmp.test


