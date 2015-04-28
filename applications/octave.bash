tmp=0
if $(is_c gnu) ; then
    tmp=1
fi
[ $tmp -eq 0 ] && return

add_package ftp://ftp.gnu.org/gnu/octave/octave-3.8.2.tar.bz2

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

# What to check for when checking for installation...
pack_set --install-query $(pack_get --prefix)/bin/octave

pack_set --host-reject zero
pack_set --host-reject ntch

# Link gnuplot (otherwise the gnuplot backend won't work)
pack_set --module-requirement gnuplot

tmp_flags="--with-x --disable-docs --disable-java"
pack_set --module-requirement arpack-ng
tmp_flags="$tmp_flags --with-arpack-libdir=$(pack_get --LD arpack-ng)"
tmp_flags="$tmp_flags --with-arpack-includedir=$(pack_get --prefix arpack-ng)/include"
pack_set --module-requirement fftw-3
tmp_flags="$tmp_flags --with-fftw3-libdir=$(pack_get --LD fftw-3)"
tmp_flags="$tmp_flags --with-fftw3-includedir=$(pack_get --prefix fftw-3)/include"
tmp_flags="$tmp_flags --with-fftw3f-libdir=$(pack_get --LD fftw-3)"
tmp_flags="$tmp_flags --with-fftw3f-includedir=$(pack_get --prefix fftw-3)/include"
pack_set --module-requirement hdf5-serial
tmp_flags="$tmp_flags --with-z-libdir=$(pack_get --LD zlib)"
tmp_flags="$tmp_flags --with-z-includedir=$(pack_get --prefix zlib)/include"
tmp_flags="$tmp_flags --with-hdf5-libdir=$(pack_get --LD hdf5-serial)"
tmp_flags="$tmp_flags --with-hdf5-includedir=$(pack_get --prefix hdf5-serial)/include"
pack_set --module-requirement umfpack
tmp_flags="$tmp_flags --without-cxsparse"
for m in amd camd colamd ccolamd cholmod umfpack ; do
    tmp_flags="$tmp_flags --with-$m-libdir=$(pack_get --LD $m)"
    tmp_flags="$tmp_flags --with-$m-includedir=$(pack_get --prefix $m)/include"
done

if $(is_c intel) ; then
    # The tmg-lib must be included...
    tmp_flags="$tmp_flags --with-blas='$MKL_LIB -lmkl_blas95_lp64 -mkl=sequential'"
    tmp_flags="$tmp_flags --with-lapack='$MKL_LIB -lmkl_lapack95_lp64 -mkl=sequential'"

else 

    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ] ; then
	    pack_set --module-requirement $la
	    tmp_ld="$(list --LDFLAGS --Wlrpath $la)"
	    tmp_flags="$tmp_flags --with-lapack='$tmp_ld -llapack'"
	    if [ "x$la" == "xatlas" ]; then
		tmp_flags="$tmp_flags --with-blas='$tmp_ld -lf77blas -lcblas -latlas'"
	    elif [ "x$la" == "xopenblas" ]; then
		tmp_flags="$tmp_flags --with-blas='$tmp_ld -lopenblas'"
	    elif [ "x$la" == "xblas" ]; then
		tmp_flags="$tmp_flags --with-blas='$tmp_ld -lblas'"
	    fi
	    break
	fi
    done

fi

# Install commands that it should run
pack_set --command "LDFLAGS='$(list --Wlrpath --LDFLAGS $(pack_get --mod-req))' ../configure $tmp_flags" \
    --command-flag "--prefix=$(pack_get --prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
#pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
#pack_set_mv_test tmp.test

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --mod-req)) \
    -L $(pack_get --alias)
