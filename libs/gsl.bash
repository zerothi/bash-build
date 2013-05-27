# Install gsl
add_package ftp://ftp.gnu.org/gnu/gsl/gsl-1.15.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libgsl.a

pack_set --host-reject "ntch-2857" --host-reject zeroth

# Install commands that it should run
if $(is_c intel) ; then
    pack_set --command "../configure" \
	--command-flag "LIBS='$MKL_LIB -mkl=sequential -lmkl_lapack95_lp64 -lmkl_blas95_lp64'" \
	--command-flag "LDFLAGS='$MKL_LIB'" \
	--command-flag "--prefix $(pack_get --install-prefix)"

elif $(is_c gnu) ; then
    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --module-requirement atlas
	pack_set --command "../configure" \
	    --command-flag "LIBS='-lm $(list --Wlrpath --LDFLAGS atlas) -lf77blas -lcblas -latlas'" \
	    --command-flag "--prefix $(pack_get --install-prefix)"
    else
	pack_set --module-requirement blas
	pack_set --module-requirement lapack
	pack_set --command "../configure" \
	    --command-flag "LIBS='-lm $(list --Wlrpath --LDFLAGS blas lapack) -llapack -lblas'" \
	    --command-flag "--prefix $(pack_get --install-prefix)"
    fi
else
    doerr gsl "Have not adapted a correct BLAS/LAPACK library"
fi

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

