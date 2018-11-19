v=3.6.3
add_package \
    --archive arpack-ng-$v.tar.gz \
    https://github.com/opencollab/arpack-ng/archive/$v.tar.gz

pack_set -s $IS_MODULE

# Required as the version has just been set
pack_set --install-query $(pack_get --LD)/libparpack.a
pack_set --lib -larpack
pack_set --lib[mpi] -lparpack -larpack

pack_set --module-requirement mpi

tmp_flags=""
if $(is_c intel) ; then
    tmp_flags="--with-blas='-mkl=sequential'"
    tmp_flags="$tmp_flags --with-lapack='-mkl=sequential'"

else

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp_flags="--with-blas='$(pack_get -lib $la)' --with-lapack='$(pack_get -lib $la)'"
    
fi

pack_cmd "module load $(pack_get --module-name build-tools)"

pack_cmd "./bootstrap"
pack_cmd "./configure" \
	 "F77='$FC' FC='$FC'" \
	 "FFLAGS='$FCFLAGS' FCLAGS='$FCFLAGS'" \
	 "MPIF77='$MPIFC' MPIFC='$MPIFC'" \
	 "--enable-mpi $tmp_flags" \
	 "--prefix=$(pack_get --prefix)"

pack_cmd "make"
pack_cmd "make install"

pack_cmd "module unload $(pack_get --module-name build-tools)"
