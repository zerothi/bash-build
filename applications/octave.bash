add_package ftp://ftp.gnu.org/gnu/octave/octave-3.8.2.tar.bz2

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# What to check for when checking for installation...
pack_set --install-query $(pack_get --prefix)/bin/octave

tmp_flags="--with-x"
pack_set --module-requirement arpack-ng
tmp_flags="$tmp_flags --with-arpack-libdir=$(pack_get --library-path arpack-ng)"
tmp_flags="$tmp_flags --with-arpack-includedir=$(pack_get --prefix arpack-ng)/include"
pack_set --module-requirement fftw-3
tmp_flags="$tmp_flags --with-fftw3-libdir=$(pack_get --library-path fftw-3)"
tmp_flags="$tmp_flags --with-fftw3-includedir=$(pack_get --prefix fftw-3)/include"
tmp_flags="$tmp_flags --with-fftw3f-libdir=$(pack_get --library-path fftw-3)"
tmp_flags="$tmp_flags --with-fftw3f-includedir=$(pack_get --prefix fftw-3)/include"
pack_set --module-requirement hdf5-serial
tmp_flags="$tmp_flags --with-z-libdir=$(pack_get --library-path zlib)"
tmp_flags="$tmp_flags --with-z-includedir=$(pack_get --prefix zlib)/include"
tmp_flags="$tmp_flags --with-hdf5-libdir=$(pack_get --library-path hdf5-serial)"
tmp_flags="$tmp_flags --with-hdf5-includedir=$(pack_get --prefix hdf5-serial)/include"
pack_set --module-requirement umfpack
tmp_flags="$tmp_flags --without-cxsparse"
for m in amd camd colamd ccolamd cholmod umfpack ; do
    tmp_flags="$tmp_flags --with-$m-libdir=$(pack_get --library-path $m)"
    tmp_flags="$tmp_flags --with-$m-includedir=$(pack_get --prefix $m)/include"
done

if $(is_c intel) ; then
    # The tmg-lib must be included...
    tmp_flags="$tmp_flags --with-blas='$MKL_LIB -lmkl_blas95_lp64 -mkl=sequential'"
    tmp_flags="$tmp_flags --with-lapack='$MKL_LIB -lmkl_lapack95_lp64 -mkl=sequential'"

else 

    if [ $(pack_installed atlas) -eq 1 ]; then
	pack_set --module-requirement atlas
	tmp_flags="$tmp_flags --with-blas='$(pack_get --library-path atlas) -lf77blas -lcblas -latlas'"
	tmp_flags="$tmp_flags --with-lapack='$(pack_get --library-path atlas) -llapack'"

    elif [ $(pack_installed openblas) -eq 1 ]; then
	pack_set --module-requirement openblas
	tmp_flags="$tmp_flags --with-blas='$(pack_get --library-path openblas) -lopenblas'"
	tmp_flags="$tmp_flags --with-lapack='$(pack_get --library-path openblas) -llapack'"

    else
	pack_set --module-requirement blas
	tmp_flags="$tmp_flags --with-blas='$(pack_get --library-path blas) -lblas'"
	tmp_flags="$tmp_flags --with-lapack='$(pack_get --library-path blas) -llapack'"

    fi

fi


# Install commands that it should run
pack_set --command "LDFLAGS='$(list --Wlrpath --LDFLAGS $(pack_get --module-requirement))' ../configure $tmp_flags" \
    --command-flag "--prefix=$(pack_get --prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test


if [ $(pack_installed flex) -eq 1 ] ; then
    pack_set --command "module unload $(pack_get --module-name flex) $(pack_get --module-name-requirement flex)"
fi
