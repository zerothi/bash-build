add_package http://icl.cs.utk.edu/projectsfiles/plasma/pubs/plasma_2.7.0.tar.gz

pack_set -s $IS_MODULE -s $MAKE_PARALLEL 

pack_set --install-query $(pack_get --LD)/libplasma.a

pack_set --module-requirement hwloc

file=make.inc
pack_set --command "echo '# Makefile for easy installation ' > $file"

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
LIBLAPACK = $MKL_LIB -lmkl_lapack95_lp64 -mkl=parallel \n' $file"

else 

    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ]; then
	    pack_set --module-requirement $la
	    tmp=
	    cblas=
	    [ "x$la" == "xatlas" ] && \
		tmp="-lf77blas -lcblas"
	    [ "x$la" == "xopenblas" ] && \
		tmp="-lopenblas_omp" || tmp="$tmp -l$la"
	    [ "x$la" == "xblas" ] && cblas="-lcblas"
	    pack_set --command "sed -i '1 a\
LIBBLAS  = $(list --LDFLAGS --Wlrpath $la) $tmp \n\
LIBCBLAS = $cblas\n\
INCCLAPACK = $(list --INCDIRS $la)\n\
LIBCLAPACK = $(list --LDFLAGS --Wlrpath $la) -llapacke \n\
LIBLAPACK  = $(list --LDFLAGS --Wlrpath $la) -ltmg -llapack\n' $file"
	    break
	fi
    done

fi
tmpfc=${FFLAGS//-fp-model /}
tmpfc=${tmpfc//precise/}
tmpfc=${tmpfc//source/}
pack_set --command "sed -i '1 a\
PLASMA_F90 =1\n\
prefix = $(pack_get --prefix)\n\
CC = $CC \n\
FC = $FC \n\
LOADER = \$(FC) \n\
ARCH = $AR \n\
ARCHFLAGS = cr \n\
RANLIB = ranlib \n\
CFLAGS = $CFLAGS $FLAG_OMP -DADD_\n\
FFLAGS = $tmpfc $FLAG_OMP \n\
LDFLAGS := \$(LDFLAGS) \$(FFLAGS) $(list --LDFLAGS --Wlrpath $(pack_get --mod-req hwloc) hwloc)\n' $file"
unset tmpfc
# Make and install commands
pack_set --command "make $(get_make_parallel) all"
pack_set --command "make test > tmp.test 2>&1"
pack_set --command "cd testing"
pack_set --command "make all"
pack_set --command "python plasma_testing.py -c 2 >> ../tmp.test 2>&1"
pack_set --command "cat testing_results.txt >> ../tmp.test"
pack_set --command "cd .."
pack_set --command "make install"
if ! $(is_host ntch) ; then
    # We also build the timings executables
    pack_set --command "cd timing"
    pack_set --command "make all"
    pack_set --command "mkdir -p $(pack_get --prefix)/bin"
    pack_set --command "cp time_*[^cho] $(pack_get --prefix)/bin/"
    pack_set --command "cd .."
fi
pack_set_mv_test tmp.test

