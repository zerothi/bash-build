add_package http://www.grycap.upv.es/slepc/download/distrib/slepc-3.10.1.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libslepc.so

pack_set --module-requirement petsc \
	 --module-requirement parpack

tmp_ld="$(list --LD-rp $(pack_get --mod-req))"
tmp_lib=

if $(is_c intel) ; then
    tmp_lib="-lmkl_blacs_openmpi_lp64 -mkl=cluster"

else

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp_ld="$tmp_ld $(list --LD-rp +$la)"
    tmp_lib="$(pack_get -lib $la)"

fi

pack_cmd "unset PETSC_ARCH"

# We need to fix d_type such that complex also works
# Should this really be a separate package???
for d_type in real
do
pack_cmd "CC='$MPICC' CFLAGS='$CFLAGS'" \
	 "CXX='$MPICXX' CXXFLAGS='$CFLAGS'" \
	 "FC='$MPIF90' FCFLAGS='$FCFLAGS'" \
	 "F77='$MPIF77' FFLAGS='$FFLAGS'" \
	 "F90='$MPIF90'" \
	 "LDFLAGS='$tmp_ld'" \
	 "LIBS='$tmp_ld $tmp_lib'" \
	 "AR=$AR" \
	 "RANLIB=ranlib" \
	 "PETSC_ARCH=$d_type" \
	 "./configure" \
	 "--prefix=$(pack_get --prefix)" \
	 "--with-arpack" \
	 "--with-arpack-dir=$(pack_get --LD parpack)" \
	 "--with-arpack-flags='-lparpack -larpack'"

# Set the arch of the build (sets the directory...)
# (pre 3.5 PETSC_ARCH=arch-installed-petsc is needed)
pack_cmd "make PETSC_ARCH=$d_type SLEPC_DIR=\$(pwd)"

#pack_cmd "make testexamples"
#pack_cmd "make testfortran"

pack_cmd "make PETSC_ARCH=$d_type install"

# Unset architecture...
pack_cmd "unset SLEPC_DIR"

# This tests the installation (i.e. linking)
pack_cmd "make PETSC_ARCH=$d_type SLEPC_DIR=$(pack_get --prefix) test > tmp.test 2>&1"
pack_set_mv_test tmp.test $d_type.test

done
pack_set --module-opt "--set-ENV SLEPC_DIR=$(pack_get --prefix)"

# Clean up the unused module
pack_cmd "rm -rf $(pack_get --LD)/modules"
