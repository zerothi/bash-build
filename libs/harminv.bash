# We will only install this on the super computer
add_package http://ab-initio.mit.edu/harminv/harminv-1.3.1.tar.gz

pack_set --host-reject ntch \
	--host-reject zeroth

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libharminv.a

    # Check for Intel MKL or not
tmp=$(get_c)
if [ "${tmp:0:5}" == "intel" ]; then
    tmp="--with-blas='-mkl=sequential $MKL_PATH/lib/intel64/libmkl_blas95_lp64.a'" 
    tmp="$tmp --with-lapack='-mkl=sequential $MKL_PATH/lib/intel64/libmkl_lapack95_lp64.a'" 

elif [ "${tmp:0:3}" == "gnu" ]; then
    pack_set --module-requirement atlas
    tmp="--with-blas='$(list --Wlrpath $(pack_get --module-requirement)) -lcblas -lf77blas -latlas'"
    tmp="$tmp --with-lapack='$(list --Wlrpath $(pack_get --module-requirement)) -llapack_atlas'"

else
    doerr harminv "Compiler unknown"

fi

    # Install commands that it should run
pack_set --command "./configure" \
    --command-flag "LDFLAGS='$LDFLAGS $(list --LDFLAGS $(pack_get --module-requirement)) $(list --Wlrpath $(pack_get --module-requirement))'" \
    --command-flag "CPPFLAGS='$CPPFLAGS $(list --INCDIRS $(pack_get --module-requirement))'" \
    --command-flag "--prefix $(pack_get --install-prefix) $tmp"


# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

pack_install
