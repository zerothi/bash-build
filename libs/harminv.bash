# We will only install this on the super computer
add_package http://ab-initio.mit.edu/harminv/harminv-1.3.1.tar.gz

pack_set \
    $(list --prefix "--host-reject " ntch zeroth surt muspel slid a0 b0 c0 d0 n0 p0 q0 g0 hemera eris ponto)

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libharminv.a

# Check for Intel MKL or not
if $(is_c intel) ; then
    tmp="--with-blas='$MKL_LIB -mkl=sequential -lmkl_blas95_lp64'" 
    tmp="$tmp --with-lapack='$MKL_LIB -mkl=sequential -lmkl_lapack95_lp64'" 

else

    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ]; then
	    pack_set --module-requirement $la
	    tmp_ld="$(list --LD-rp $la)"
	    tmp=
	    [ "x$la" == "xatlas" ] && \
		tmp="-lf77blas -lcblas"
	    tmp="$tmp -l$la"
	    tmp="--with-blas='$tmp_ld $tmp' --with-lapack='$tmp_ld -llapack'"
	    break
	fi
    done

fi

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "CPPFLAGS='$CPPFLAGS $(list --INCDIRS $(pack_get --mod-req-path))'" \
    --command-flag "--prefix $(pack_get --prefix) $tmp"


# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

