# We will only install this on the super computer
add_package http://ab-initio.mit.edu/harminv/harminv-1.3.1.tar.gz

pack_set --host-reject ntch --host-reject zeroth \
    $(list --prefix "--host-reject " surt muspel slid a0 b0 c0 d0 n0 p0 q0 g0 hemera eris)

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libharminv.a

# Check for Intel MKL or not
if $(is_c intel) ; then
    tmp="--with-blas='$MKL_LIB -mkl=sequential -lmkl_blas95_lp64'" 
    tmp="$tmp --with-lapack='$MKL_LIB -mkl=sequential -lmkl_lapack95_lp64'" 

else
    if [ $(pack_installed atlas) -eq 1 ]; then
	pack_set --module-requirement atlas
	tmp="--with-blas='-lf77blas -lcblas -latlas'"
	tmp="$tmp --with-lapack='-llapack -lf77blas -lcblas -latlas'"
    elif [ $(pack_installed openblas) -eq 1 ]; then
	pack_set --module-requirement openblas
	tmp="--with-blas='-lopenblas' --with-lapack='-llapack'"
    else
	pack_set --module-requirement blas
	tmp="--with-blas='-lblas'"
	tmp="$tmp --with-lapack='-llapack'"
    fi

fi

    # Install commands that it should run
pack_set --command "./configure" \
    --command-flag "LDFLAGS='$LDFLAGS $(list --LDFLAGS $(pack_get --mod-req)) $(list --Wlrpath $(pack_get --mod-req))'" \
    --command-flag "CPPFLAGS='$CPPFLAGS $(list --INCDIRS $(pack_get --mod-req))'" \
    --command-flag "--prefix $(pack_get --prefix) $tmp"


# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

