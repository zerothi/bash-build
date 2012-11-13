
# We will only install this on the super computer
tmp="$(hostname)"
if [ "${tmp:0:2}" == "n-" ]; then
    
    add_package http://ab-initio.mit.edu/harminv/harminv-1.3.1.tar.gz
    
    pack_set -s $MAKE_PARALLEL -s $IS_MODULE
    
    pack_set --install-query $(pack_get --install-prefix)/lib/libharminv.a

    # Check for Intel MKL or not
    tmp=$(get_c)
    if [ "${tmp:0:5}" == "intel" ]; then
        tmp="--with-blas='-mkl=sequential $MKL_PATH/lib/intel64/libmkl_blas95_lp64.a'" 
	tmp="$tmp --with-lapack='-mkl=sequential $MKL_PATH/lib/intel64/libmkl_lapack95_lp64.a'" 

    elif [ "${tmp:0:3}" == "gnu" ]; then
        pack_set --module-requirement lapack \
            --module-requirement atlas
	tmp=$(pack_get --install-prefix atlas)/lib
        tmp="--with-blas='$tmp/libcblas.a $tmp/libf77blas.a $tmp/libatlas.a' --with-lapack='$tmp/liblapack_atlas.a'"

    else
	doerr harminv "Compiler unknown"

    fi

    tmp_ld="" ; tmp_cpp=""
    for cmd in $(pack_get --module-requirement) ; do
        tmp_ld="$tmp_ld -L$(pack_get --install-prefix $cmd)/lib"
        tmp_cpp="$tmp_cpp -I$(pack_get --install-prefix $cmd)/include"
    done

    # Install commands that it should run
    pack_set --command "./configure" \
	--command-flag "LDFLAGS='$LDFLAGS $tmp_ld'" \
	--command-flag "CPPFLAGS='$CPPFLAGS $tmp_cpp'" \
	--command-flag "--prefix $(pack_get --install-prefix) $tmp"
    

# Make commands
    pack_set --command "make $(get_make_parallel)"
    pack_set --command "make" \
	--command-flag "install"
    
    pack_install
fi