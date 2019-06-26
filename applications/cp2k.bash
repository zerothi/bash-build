add_package https://github.com/cp2k/cp2k/releases/download/v6.1.0/cp2k-6.1.tar.bz2

pack_set $(list -p '-module-requirement ' mpi libxc fftw)

pack_set -install-query $(pack_get -prefix)/bin/cp2k.psmp

# Add the lua family
pack_set -module-opt "-lua-family $(pack_get -alias)"

if [[ -z "$FLAG_OMP" ]]; then
    doerr $(pack_get -package) "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi

# Find hwloc library
tmp_hwloc=$(pack_get -mod-req[hwloc])

arch=Linux-x86-64-NPA
file=arch/$arch.psmp
pack_cmd "echo '# NPA' > $file"

# Only one of HWLOC/LIBNUMA
pack_cmd "sed -i '1 a\
CPP = \n\
FC = $MPIFC \n\
LD = $MPIFC \n\
AR = $AR -r \n\
HWLOC_INC = $(list -INCDIRS $tmp_hwloc) \n\
HWLOC_LIB = $(list -LD-rp $tmp_hwloc) \n\
FFTW_INC = $(list -INCDIRS fftw) \n\
FFTW_LIB = $(list -LD-rp fftw) \n\
LIBXC_INC = $(list -INCDIRS libxc) \n\
LIBXC_LIB = $(list -LD-rp libxc) \n\
DFLAGS  = -D__FFTW3 -D__HWLOC \n\
DFLAGS += -D__parallel -D__SCALAPACK\n\
DFLAGS += -D__LIBXC\n\
#DFLAGS  += -D__ELPA \n\
CC = $CC \$(DFLAGS) $CFLAGS \$(HWLOC_INC) \n\
CPPFLAGS = \$(DFLAGS) \n\
FCFLAGS += \$(DFLAGS) $FCFLAGS $FLAG_OMP \$(FFTW_INC) \$(LIBXC_INC) \n\
LDFLAGS = \$(FCFLAGS) \n\
LIBS  = \$(FFTW_LIB) -lfftw3_omp -lfftw3 \n\
LIBS += \$(HWLOC_LIB) -lhwloc \n\
LIBS += \$(LIBXC_LIB) $(pack_get -lib libxc) \n\
LIBS += \$(SCALAPACK_L) \$(LAPACK_L) \n\
' $file"

if $(is_c intel) ; then

    pack_cmd "sed -i '$ a\
LAPACK_L = -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -mkl=sequential\n\
SCALAPACK_L = -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 \n\
FCFLAGS += -free\n\
LDFLAGS += -nofor_main\n\
' $file"

elif $(is_c gnu) ; then
    pack_set -module-requirement scalapack

    pack_cmd "sed -i '$ a\
FCFLAGS += -ffree-form -ffree-line-length-none \n\
SCALAPACK_L = $(list -LD-rp scalapack) -lscalapack \n\
' $file"

    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    tmp_ld="$(list -LD-rp +$la)"
    pack_cmd "sed -i '1 a\
LAPACK_L = $tmp_ld $(pack_get -lib[omp] $la)\n\
' $file"

else
    doerr $(pack_get -package) "Could not determine compiler: $(get_c)"
    
fi

pack_cmd "cd makefiles"

pack_cmd "make $(get_make_parallel) ARCH=$arch VERSION=psmp"

pack_cmd "mkdir -p $(pack_get -prefix)/bin"
pack_cmd "cp ../exe/$arch/* $(pack_get -prefix)/bin"
