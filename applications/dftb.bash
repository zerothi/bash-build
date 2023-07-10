for v in 18.2 19.1 22.2
do
add_package http://www.dftbplus.org/fileadmin/DFTBPLUS/public/dftbplus/$v/dftbplus-$v.tar.xz

pack_set -s $MAKE_PARALLEL

pack_set --module-opt "--lua-family dftb+"

pack_set --module-requirement arpack-ng
pack_set --module-requirement mpi

pack_set --install-query $(pack_get --prefix)/bin/dftb+


pack_cmd "sed -i -e 's:/bin/env python:/bin/env python3:' external/fypp/bin/fypp"

# Check for Intel MKL or not
if $(is_c intel) ; then
    cc=intel
elif $(is_c gnu) ; then
    cc=gnu
fi
file=make.arch
pack_cmd "echo '#' > $file"
pack_cmd "sed -i '$ a\
FXX = $MPIFC\n\
FXXOPT = $FCFLAGS $FLAG_OMP\n\
CC = $CC\n\
FYPP = \$(ROOT)/external/fypp/bin/fypp\n\
FYPPOPT = \n\
LN = \$(FXX) \n\
LIBOPT = \n\
M4 = m4\n\
M4OPT = \n\
OTHERLIBS = \n' $file"

if [[ -z "$FLAG_OMP" ]]; then
    doerr dftb "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi

# Check for Intel MKL or not
if $(is_c intel) ; then
    pack_cmd "sed -i '$ a\
LNOPT = -qmkl=parallel $FLAG_OMP\n\
LIB_SCALAPACK= $MKL_LIB -lmkl_scalapack_lp64 -lmkl_blacs_intelmpi_lp64\n\
LIB_LAPACK = $MKL_LIB -lmkl_lapack95_lp64\n\
LIB_BLAS = $MKL_LIB -lmkl_blas95_lp64\n' $file"

else
    pack_cmd "sed -i '$ a\
LNOPT = $FLAG_OMP\n' $file"

    pack_set --module-requirement scalapack
    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    pack_cmd "sed -i '$ a\
LINALG_OPT = $(list --LD-rp scalapack ++$la)\n\
LIB_SCALAPACK= -lscalapack\n\
LIB_LAPACK = \$(LINALG_OPT) $(pack_get -lib[omp] $la)\n\
LIB_BLAS = \$(LINALG_OPT) $(pack_get -lib[omp] $la)\n' $file"

fi

pack_cmd "echo '#' > make.config"
pack_cmd "sed -i '$ a\
BUILDDIR = \$(ROOT)/build\n\
INSTALLDIR = $(pack_get --prefix)\n\
WITH_MPI = 1\n\
WITH_DFTD3 = 0\n\
COMPILE_DFTD3 = 0\n\
WITH_ARPACK = 1\n\
WITH_SOCKETS = 1\n\
DEBUG = 0\n\
ARPACK_LIBS = $(list -LD-rp arpack-ng) $(pack_get --lib[mpi] arpack-ng)\n\
ARPACK_NEEDS_LAPACK = 1\n\
include \$(ROOT)/make.arch\n' make.config"

pack_cmd "make $(get_make_parallel)"

# Make commands
pack_cmd "make install"

done
