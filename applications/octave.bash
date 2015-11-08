tmp=0
if $(is_c gnu) ; then
    tmp=1
fi
[[ $tmp -eq 0 ]] && return

add_package ftp://ftp.gnu.org/gnu/octave/octave-4.0.0.tar.xz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

# What to check for when checking for installation...
pack_set --install-query $(pack_get --prefix)/bin/octave

# Link gnuplot (otherwise the gnuplot backend won't work)
pack_set --module-requirement gnuplot
if [[ $(pack_get --installed pcre) -ge $_I_INSTALLED ]]; then
    pack_set -mod-req pcre
fi

tmp_flags="--with-x --disable-docs --disable-java"
tmp_flags="$tmp_flags --without-fltk"
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
tmp_flags="$tmp_flags --without-cxsparse"
for m in glpk amd camd colamd ccolamd cholmod umfpack ; do
    pack_set --module-requirement $m
    tmp_flags="$tmp_flags --with-$m-libdir=$(pack_get --LD $m)"
    tmp_flags="$tmp_flags --with-$m-includedir=$(pack_get --prefix $m)/include"
done

if $(is_c intel) ; then
    tmp_flags="$tmp_flags --with-blas='$MKL_LIB -lmkl_blas95_lp64 -mkl=sequential'"
    tmp_flags="$tmp_flags --with-lapack='$MKL_LIB -lmkl_lapack95_lp64 -mkl=sequential'"

else 

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la

    tmp_ld="$(list --LD-rp +$la)"
    tmp_flags="$tmp_flags --with-lapack='$tmp_ld $(pack_get -lib $la)'"
    tmp_flags="$tmp_flags --with-blas='$tmp_ld $(pack_get -lib $la)'"

fi

# Install commands that it should run
pack_cmd "LDFLAGS='$(list --LD-rp $(pack_get --mod-req))' ../configure $tmp_flags" \
    "--prefix=$(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
#pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"
#pack_set_mv_test tmp.test
