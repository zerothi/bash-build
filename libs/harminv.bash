# We will only install this on the super computer
v=1.4.2
add_package https://github.com/NanoComp/harminv/releases/download/v$v/harminv-$v.tar.gz

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

pack_cmd "./configure" \
	 "CPPFLAGS='$CPPFLAGS $(list --INCDIRS $(pack_get --mod-req-path))'" \
	 "--prefix $(pack_get --prefix) $tmp"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

