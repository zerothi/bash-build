# Install gsl
add_package ftp://ftp.gnu.org/gnu/gsl/gsl-1.16.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libgsl.a

# Install commands that it should run
if $(is_c intel) ; then
    pack_set --command "../configure" \
	--command-flag "LIBS='$MKL_LIB -mkl=sequential -lmkl_lapack95_lp64 -lmkl_blas95_lp64'" \
	--command-flag "LDFLAGS='$MKL_LIB'" \
	--command-flag "--prefix $(pack_get --prefix)"

else
    if [ $(pack_installed atlas) -eq 1 ]; then
	pack_set --module-requirement atlas
	tmp="$(list --Wlrpath --LDFLAGS atlas) -llapack -lf77blas -lcblas -latlas"
    elif [ $(pack_installed openblas) -eq 1 ]; then
	pack_set --module-requirement openblas
	tmp="$(list --Wlrpath --LDFLAGS openblas) -llapack -lopenblas"
    else
	pack_set --module-requirement blas
	tmp="$(list --Wlrpath --LDFLAGS blas) -llapack -lblas"
    fi
    pack_set --command "../configure" \
	--command-flag "LIBS='-lm $tmp'" \
	--command-flag "--prefix $(pack_get --prefix)"
fi

# Make commands
pack_set --command "make $(get_make_parallel)"
if ! $(is_c intel) ; then
    pack_set --command "make check > tmp.test 2>&1"
fi
pack_set --command "make install"
if ! $(is_c intel) ; then
    pack_set_mv_test tmp.test
fi


