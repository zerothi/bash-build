v=2023.1
add_package https://github.com/cp2k/cp2k/releases/download/v$v/cp2k-$v.tar.bz2

pack_set -s $MAKE_PARALLEL

pack_set $(list -p '-module-requirement ' mpi libxc fftw libint spglib libxsmm)

pack_set -install-query $(pack_get -prefix)/bin/cp2k.popt

pack_set -host-reject $(get_hostname)

# Add the lua family
pack_set -module-opt "-lua-family $(pack_get -alias)"

# Find hwloc library
tmp_hwloc=$(pack_get -mod-req[hwloc])

# cp2k recommends using non-threaded BLAS for OPENMP compilation

pack_cmd "mkdir -p $(pack_get -prefix)/bin"
pack_cmd "cp -rf data $(pack_get -prefix)/"

arch=Linux-x86-64-NPA
file=arch/$arch.popt
pack_cmd "echo '# NPA' > $file"

# Only one of HWLOC/LIBNUMA
pack_cmd "sed -i '1 a\
DATA_DIR = $(pack_get -prefix)/data\n\
CPP = \n\
CC = $MPICC \n\
FC = $MPIFC \n\
LD = $MPIFC \n\
AR = $AR -r \n\
FCFLAGS = $FCFLAGS \n\
HWLOC_INC = $(list -INCDIRS $tmp_hwloc) \n\
HWLOC_LIB = $(list -LD-rp $tmp_hwloc) \n\
FFTW_INC = $(list -INCDIRS fftw) \n\
FFTW_LIB = $(list -LD-rp fftw) \n\
LIBXC_INC = $(list -INCDIRS libxc) \n\
LIBXC_LIB = $(list -LD-rp libxc) \n\
DFLAGS  = -D__F2008 -D__FFTW3 -D__HWLOC -D__SPGLIB \n\
DFLAGS += -D__MPI_VERSION=3 \n\
DFLAGS += -D__parallel -D__SCALAPACK \n\
DFLAGS += -D__LIBXC\n\
DFLAGS += -D__LIBXSMM\n\
DFLAGS += -D__LIBINT -D__MAX_CONTR=4\n\
#DFLAGS += -D__ELPA \n\
CFLAGS = $CFLAGS \n\
CPPFLAGS = \$(DFLAGS) \n\
FCFLAGS += \$(DFLAGS) \$(FFTW_INC) \$(LIBXC_INC) -I$(pack_get -prefix libxsmm)/include -I$(pack_get -prefix libint)/include\n\
LDFLAGS = \$(FCFLAGS) \n\
LIBS  = \$(FFTW_LIB) $(pack_get -lib fftw) \n\
LIBS += \$(HWLOC_LIB) -lhwloc \n\
LIBS += \$(LIBXC_LIB) $(pack_get -lib libxc) \n\
LIBS += $(list -LD-rp libint) $(pack_get -lib libint) \n\
LIBS += $(list -LD-rp spglib) $(pack_get -lib spglib) \n\
LIBS += $(list -LD-rp libxsmm) $(pack_get -lib[f] libxsmm) \n\
LIBS += \$(SCALAPACK_L) \$(LAPACK_L) \n\
LIBS += -ldl \n\
' $file"

if $(is_c intel) ; then

    pack_cmd "sed -i '$ a\
LAPACK_L = -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -qmkl=sequential\n\
SCALAPACK_L = -lmkl_scalapack_lp64 -lmkl_blacs_intelmpi_lp64 \n\
FCFLAGS += -free\n\
LDFLAGS += -nofor_main\n\
DFLAGS += -D__MKL -D__INTEL_COMPILER \n\
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
LAPACK_L = $tmp_ld $(pack_get -lib $la)\n\
' $file"

else
    doerr $(pack_get -package) "Could not determine compiler: $(get_c)"
    
fi

pack_cmd "unset FCFLAGS ; unset FFLAGS ; unset CFLAGS ; unset LDFLAGS"

pack_cmd "make $(get_make_parallel) ARCH=$arch VERSION=popt"
pack_cmd "make ARCH=$arch VERSION=popt TESTOPTS='-ompthreads 1 -mpiranks $NPROCS -maxtasks $NPROCS' test > cp2k.test 2>&1"
pack_store cp2k.test
pack_cmd "cp ../exe/$arch/* $(pack_get -prefix)/bin"
