add_package https://bitbucket.org/icl/plasma/downloads/plasma-21.8.29.tar.gz

pack_set -s $IS_MODULE -s $MAKE_PARALLEL 

pack_set --install-query $(pack_get --LD)/libplasma.a
pack_set -module-requirement lua

file=make.inc
pack_cmd "echo '# Makefile for easy installation ' > $file"

if [[ -z "$FLAG_OMP" ]]; then
    doerr PLASMA "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi

# We will create our own makefile from scratch (the included ones are ****)
if $(is_c intel) ; then
    # The tmg-lib must be included...
    pack_cmd "sed -i '1 a\
CFLAGS  += -DHAVE_MKL \n\
INC = -I$MKL_PATH/include\n\
LIBS = $MKL_LIB -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -mkl=parallel \n' $file"

else 
    
    la=$(pack_choice -i linalg)
    lla=lapack-$la
    pack_set -module-requirement $lla

    pack_cmd "sed -i '1 a\
LIBS = $(list --LD-rp-lib[omp] $la) \n' $file"

fi
tmpfc=${FFLAGS//-fp-model /}
tmpfc=${tmpfc//precise/}
tmpfc=${tmpfc//source/}
pack_cmd "sed -i '1 a\
lua_platform = linux\n\
lua_dir
fortran = 1\n\
CC = $CC \n\
FC = $FC \n\
AR = $AR \n\
prefix = $(pack_get -prefix)\n\
RANLIB = $RANLIB \n\
CFLAGS = $CFLAGS $FLAG_OMP\n\
FCFLAGS = $FFLAGS $FLAG_OMP \n\
LDFLAGS := \$(LDFLAGS) $FLAG_OMP\n' $file"

# Make and install commands
pack_cmd "make $(get_make_parallel) all"
pack_cmd "make test > plasma.test 2>&1"
pack_cmd "cd testing"
pack_cmd "make all"
pack_cmd "python plasma_testing.py -c 2 >> ../plasma.test 2>&1"
pack_cmd "cat testing_results.txt >> ../plasma.test"
pack_cmd "cd .."
pack_cmd "make install"
if ! $(is_host ntch) ; then
    # We also build the timings executables
    pack_cmd "cd timing"
    pack_cmd "make all"
    pack_cmd "mkdir -p $(pack_get --prefix)/bin"
    pack_cmd "cp time_*[^cho] $(pack_get --prefix)/bin/"
    pack_cmd "cd .."
fi
pack_store plasma.test

