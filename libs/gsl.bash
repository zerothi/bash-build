# Install gsl
add_package ftp://ftp.gnu.org/gnu/gsl/gsl-1.15.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libgsl.a

# Install commands that it should run
tmp=$(get_c)
if [ "${tmp:0:5}" == "intel" ]; then
    pack_set --command "../configure" \
	--command-flag "LIBS='-mkl=sequential $MKL_PATH/lib/intel64/libmkl_lapack95_lp64.a $MKL_PATH/lib/intel64/libmkl_blas95_lp64.a'" \
	--command-flag "LDFLAGS='-L$MKL_PATH/lib/intel64'" \
	--command-flag "--prefix $(pack_get --install-prefix)"

elif [ "${tmp:0:3}" == "gnu" ]; then
    pack_set --module-requirement atlas
    pack_set --command "../configure" \
	--command-flag "LIBS='-lf77blas -lcblas -latlas'" \
	--command-flag "LDFLAGS='$(list --LDFLAGS $(pack_get --module-requirement))'" \
	--command-flag "--prefix $(pack_get --install-prefix)"

else
    doerr gsl "Have not adapted a correct BLAS/LAPACK library"
fi

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

pack_install
