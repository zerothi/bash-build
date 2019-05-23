for d_type in d z
do
add_package --package slepc-$d_type \
        http://slepc.upv.es/download/distrib/slepc-3.11.1.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libslepc.so

pack_set --module-requirement petsc-$d_type \
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

case $d_type in
    d)
	tmp_arch='real'
	;;
    z)
	tmp_arch='complex'
	;;
esac

pack_cmd "unset PETSC_ARCH"
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
pack_cmd "unset SLEPC_DIR"

# This tests the installation (i.e. linking)
pack_cmd "make SLEPC_DIR=$(pack_get --prefix) test > slepc.test 2>&1"
pack_store slepc.test

pack_set --module-opt "--set-ENV SLEPC_DIR=$(pack_get --prefix)"

# Clean up the unused module
pack_cmd "rm -rf $(pack_get --LD)/modules"

done
