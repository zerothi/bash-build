for v in 17.1 ; do
add_package --archive dftbplus-$v.tar.gz \
	    https://github.com/dftbplus/dftbplus/archive/$v.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --host-reject ntch-l

pack_set --module-opt "--lua-family dftb+"

pack_set --module-requirement arpack-ng

pack_set --install-query $(pack_get --prefix)/bin/dftb+

# Check for Intel MKL or not
if $(is_c intel) ; then
    cc=intel
elif $(is_c gnu) ; then
    cc=gnu
fi
file=make.arch
pack_cmd "echo '#' > $file"
pack_cmd "sed -i '$ a\
FXX = $FC\n\
FXXOPT = $FCFLAGS $FLAG_OMP\n\
CC = $CC\n\
CPP = cpp -traditional\n\
CPPOPT = \n\
FPP = \$(ROOT)/utils/build/fpp/fpp.sh general\n\
LN = \$(FXX) \n\
LIBOPT = \n\
OTHERLIBS = \n' $file"

if [[ -z "$FLAG_OMP" ]]; then
    doerr dftb "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi

# Check for Intel MKL or not
if $(is_c intel) ; then
    pack_cmd "sed -i '$ a\
LNOPT = -mkl=parallel $FLAG_OMP\n\
LIB_LAPACK = $MKL_LIB -lmkl_lapack95_lp64\n\
LIB_BLAS = $MKL_LIB -lmkl_blas95_lp64\n' $file"
    
else
    pack_cmd "sed -i '$ a\
LNOPT = $FLAG_OMP\n' $file"

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    pack_cmd "sed -i '$ a\
LINALG_OPT = $(list --LD-rp ++$la)\n\
LIB_LAPACK = \$(LINALG_OPT) $(pack_get -lib[omp] $la)\n\
LIB_BLAS = \$(LINALG_OPT) $(pack_get -lib[omp] $la)\n' $file"

fi

pack_cmd "echo '#' > make.config"
pack_cmd "sed -i '$ a\
BUILDDIR = \$(ROOT)/build\n\
INSTALLDIR = $(pack_get --prefix)\n\
WITH_DFTD3 = 0\n\
COMPILE_DFTD3 = 0\n\
WITH_ARPACK = 1\n\
ARPACK_LIBS = $(list -LD-rp arpack-ng) $(pack_get --lib arpack-ng)\n\
DEBUG = 0\n\
include \$(ROOT)/make.arch\n' make.config"

pack_cmd "make $(get_make_parallel)"

# Make commands
pack_cmd "make install"

done
