# We will only install this on the super computer
add_package http://ab-initio.mit.edu/harminv/harminv-1.4.tar.gz

pack_set $(list --prefix "--host-reject " ntch zeroth)

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libharminv.a

# Check for Intel MKL or not
if $(is_c intel) ; then
    tmp="--with-blas='$MKL_LIB -mkl=sequential -lmkl_blas95_lp64'" 
    tmp="$tmp --with-lapack='$MKL_LIB -mkl=sequential -lmkl_lapack95_lp64'" 

else

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp_ld="$(list --LD-rp +$la)"
    tmp=$(pack_get -lib $la)
    tmp="--with-blas='$tmp_ld $tmp' --with-lapack='$tmp_ld $tmp'"

fi

# Install commands that it should run
pack_cmd "./configure" \
	 "CPPFLAGS='$CPPFLAGS $(list --INCDIRS $(pack_get --mod-req-path))'" \
	 "--prefix $(pack_get --prefix) $tmp"


# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

