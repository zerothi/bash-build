add_package http://sourceforge.net/projects/cp2k/files/cp2k-2.6.1.tar.bz2

pack_set --host-reject ntch --host-reject zeroth

pack_set $(list -p '--module-requirement ' mpi libxc fftw-3)

pack_set --install-query $(pack_get --prefix)/bin/cp2k.psmp

# Add the lua family
pack_set --module-opt "--lua-family $(pack_get --alias)"

if test -z "$FLAG_OMP" ; then
    doerr $(pack_get --package) "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi

arch=Linux-x86-64-NPA
file=arch/$arch.psmp
pack_set --command "echo '# NPA' > $file"

# Only one of HWLOC/LIBNUMA
pack_set --command "sed -i '1 a\
CPP = \n\
FC = $MPIFC \n\
LD = $MPIFC \n\
AR = $AR -r \n\
HWLOC_INC = $(list -INCDIRS hwloc) \n\
HWLOC_LIB = $(list --LD-rp hwloc) \n\
FFTW_INC = $(list -INCDIRS fftw-3) \n\
FFTW_LIB = $(list --LD-rp fftw-3) \n\
LIBXC_INC = $(list -INCDIRS libxc) \n\
LIBXC_LIB = $(list --LD-rp libxc) \n\
DFLAGS  = -D__FFTW3 -D__HWLOC \n\
DFLAGS += -D__LIBXC2 -D__parallel -D__SCALAPACK\n\
DFLAGS += -D__HAS_NO_MPI_MOD \n\
CC = $CC \$(DFLAGS) $CFLAGS \$(HWLOC_INC) \n\
CPPFLAGS = \$(DFLAGS) \n\
FCFLAGS = \$(DFLAGS) $FCFLAGS $FLAG_OMP \$(FFTW_INC) \$(LIBXC_INC) \n\
LDFLAGS = \$(FCFLAGS) \n\
LIBS  = \$(FFTW_LIB) -lfftw3_omp -lfftw3 \n\
LIBS += \$(HWLOC_LIB) -lhwloc \n\
LIBS += \$(LIBXC_LIB) -lxcf90 -lxc \n\
LIBS += \$(SCALAPACK_L) \$(LAPACK_L) \n\
' $file"

if $(is_c intel) ; then

    pack_set --command "sed -i '1 a\
LAPACK_L = -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -mkl=sequential\n\
SCALAPACK_L = -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 \n\
' $file"

elif $(is_c gnu) ; then

    pack_set --command "sed -i '$ a\
FCFLAGS += -ffree-form -ffree-line-length-none \n\
' $file"

    # We use a c-linker (which does not add gfortran library)
    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ] ; then
	    pack_set --module-requirement $la
	    tmp_ld="$(list --LD-rp $la)"
	    pack_set --command "sed -i '1 a\
SCALAPACK_L = $tmp_ld -lscalapack \n\
' $file"
	    if [ "x$la" == "xatlas" ]; then
		pack_set --command "sed -i '1 a\
LAPACK_L = $tmp_ld -llapack -lf77blas -lcblas -latlas\n\
' $file"
	    elif [ "x$la" == "xopenblas" ]; then
		pack_set --command "sed -i '1 a\
LAPACK_L = $tmp_ld -llapack -lopenblas_omp\n\
' $file"
	    elif [ "x$la" == "xblas" ]; then
		pack_set --command "sed -i '1 a\
LAPACK_L = $tmp_ld -llapack -lblas\n\
' $file"
	    fi
	    break
	fi
    done

else
    doerr $(pack_get --package) "Could not determine compiler: $(get_c)"
    
fi

pack_set --command "cd makefiles"

pack_set --command "make $(get_make_parallel) ARCH=$arch VERSION=psmp"

pack_set --command "mkdir -p $(pack_get --prefix)/bin"
pack_set --command "cp ../exe/$arch/* $(pack_get --prefix)/bin"

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --mod-req)) \
    -L $(pack_get --alias)
