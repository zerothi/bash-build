add_package http://www.grycap.upv.es/slepc/download/distrib/slepc-3.6.1.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libslepc.so

pack_set --module-requirement petsc \
	 --module-requirement parpack

tmp_ld="$(list --LD-rp $(pack_get --mod-req))"
tmp_lib=

if $(is_c intel) ; then
    tmp_lib="-lmkl_blacs_openmpi_lp64 -mkl=cluster"

else

    for la in $(choice linalg) ; do
	if [[ $(pack_installed $la) -eq 1 ]]; then
	    pack_set --module-requirement $la
	    tmp_ld="$tmp_ld $(list --LD-rp $la)"
	    tmp_lib="-llapack"
	    [[ "x$la" == "xatlas" ]] && \
		tmp_lib="$tmp_lib -lf77blas -lcblas"
	    tmp_lib="$tmp_lib -l$la"
	    break
	fi
    done

fi

pack_cmd "CC='$MPICC' CFLAGS='$CFLAGS'" \
	 "CXX='$MPICXX' CXXFLAGS='$CFLAGS'" \
	 "FC='$MPIF90' FCFLAGS='$FCFLAGS'" \
	 "F77='$MPIF77' FFLAGS='$FFLAGS'" \
	 "F90='$MPIF90'" \
	 "LDFLAGS='$tmp_ld'" \
	 "LIBS='$tmp_ld $tmp_lib'" \
	 "AR=$AR" \
	 "RANLIB=ranlib" \
	 "./configure" \
	 "--prefix=$(pack_get --prefix)" \
	 "--with-arpack" \
	 "--with-arpack-dir=$(pack_get --LD parpack)" \
	 "--with-arpack-flags='-lparpack -larpack'"

# Set the arch of the build (sets the directory...)
# (pre 3.5 PETSC_ARCH=arch-installed-petsc is needed)
pack_cmd "make SLEPC_DIR=\$(pwd)"

#pack_cmd "make testexamples"
#pack_cmd "make testfortran"

pack_cmd "make install"

# Unset architecture...
pack_cmd "unset PETSC_ARCH"
pack_cmd "unset SLEPC_DIR"

# This tests the installation (i.e. linking)
pack_cmd "make SLEPC_DIR=$(pack_get --prefix) test > tmp.test 2>&1"
pack_set_mv_test tmp.test

pack_set --module-opt "--set-ENV SLEPC_DIR=$(pack_get --prefix)"

# Clean up the unused module
pack_cmd "rm -rf $(pack_get --LD)/modules"
