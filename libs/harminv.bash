# We will only install this on the super computer
add_package http://ab-initio.mit.edu/harminv/harminv-1.3.1.tar.gz

pack_set --host-reject ntch --host-reject zeroth \
    $(list --prefix "--host-reject " thul surt slid etse a0 b0 c0 d0 n0 p0 q0 g0)

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libharminv.a

# Check for Intel MKL or not
if $(is_c intel) ; then
    tmp="--with-blas='$MKL_LIB -mkl=sequential -lmkl_blas95_lp64'" 
    tmp="$tmp --with-lapack='$MKL_LIB -mkl=sequential -lmkl_lapack95_lp64'" 

elif $(is_c gnu) ; then
    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --module-requirement atlas
	tmp="--with-blas='$(list --Wlrpath atlas) -lcblas -lf77blas -latlas'"
	tmp="$tmp --with-lapack='$(list --Wlrpath atlas) -llapack_atlas'"
    else
	pack_set --module-requirement blas
	pack_set --module-requirement lapack
	tmp="--with-blas='$(list --Wlrpath blas) -lblas'"
	tmp="$tmp --with-lapack='$(list --Wlrpath lapack) -llapack'"
    fi
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

