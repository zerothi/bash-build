add_package ftp://ftp.gnu.org/gnu/octave/octave-6.4.0.tar.lz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

# What to check for when checking for installation...
pack_set -install-query $(pack_get -prefix)/bin/octave

# Link gnuplot (otherwise the gnuplot backend won't work)
pack_set -module-requirement gnuplot
if [[ $(pack_get -installed pcre) -ge $_I_INSTALLED ]]; then
    pack_set -mod-req pcre
fi
if [[ $(pack_get -installed readline) -ge $_I_INSTALLED ]]; then
    pack_set -mod-req readline
fi

tmp_flags="--with-x --disable-docs --disable-java"
tmp_flags="$tmp_flags --without-fltk"
pack_set -module-requirement arpack-ng
tmp_flags="$tmp_flags --with-arpack-libdir=$(pack_get -LD arpack-ng)"
tmp_flags="$tmp_flags --with-arpack-includedir=$(pack_get -prefix arpack-ng)/include"
pack_set -module-requirement fftw
tmp_flags="$tmp_flags --with-fftw3-libdir=$(pack_get -LD fftw)"
tmp_flags="$tmp_flags --with-fftw3-includedir=$(pack_get -prefix fftw)/include"
tmp_flags="$tmp_flags --with-fftw3f-libdir=$(pack_get -LD fftw)"
tmp_flags="$tmp_flags --with-fftw3f-includedir=$(pack_get -prefix fftw)/include"
pack_set -module-requirement qhull
tmp_flags="$tmp_flags --with-qhull-libdir=$(pack_get -LD qhull)"
tmp_flags="$tmp_flags --with-qhull-includedir=$(pack_get -prefix qhull)/include"
pack_set -module-requirement hdf5-serial
tmp_flags="$tmp_flags --with-z-libdir=$(pack_get -LD zlib)"
tmp_flags="$tmp_flags --with-z-includedir=$(pack_get -prefix zlib)/include"
tmp_flags="$tmp_flags --with-hdf5-libdir=$(pack_get -LD hdf5-serial)"
tmp_flags="$tmp_flags --with-hdf5-includedir=$(pack_get -prefix hdf5-serial)/include"
for m in glpk ; do
    pack_set -module-requirement $m
    tmp_flags="$tmp_flags --with-$m-libdir=$(pack_get -LD $m)"
    tmp_flags="$tmp_flags --with-$m-includedir=$(pack_get -prefix $m)/include"
done

pack_set -module-requirement suitesparse
tmp=$(pack_get -prefix suitesparse)
for m in suitesparseconfig amd camd colamd ccolamd cholmod klu umfpack cxsparse ; do
    tmp_flags="$tmp_flags --with-$m-libdir=$tmp/lib"
    tmp_flags="$tmp_flags --with-$m-includedir=$tmp/include"
done

if $(is_c intel) ; then
    tmp_flags="$tmp_flags --with-blas='$MKL_LIB -mkl=parallel'"
    tmp_flags="$tmp_flags --with-lapack='$MKL_LIB -mkl=parallel'"

else 

    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la

    tmp_ld="$(list -LD-rp +$la)"
    tmp_flags="$tmp_flags --with-lapack='$tmp_ld $(pack_get -lib[omp] $la)'"
    tmp_flags="$tmp_flags --with-blas='$tmp_ld $(pack_get -lib[omp] $la)'"

fi

# correct locations for not searching system-wide installations
pack_cmd "sed -i -e 's:in suitesparse/:in not_suitesparse_global/:g' ../configure"

# Install commands that it should run
pack_cmd "LDFLAGS='$(list -LD-rp $(pack_get -mod-req))' CPPFLAGS='$(list -INCDIRS $(pack_get -mod-req))' ../configure $tmp_flags" \
    "--prefix=$(pack_get -prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)" 
pack_cmd "make check > octave.test 2>&1 || echo forced"
pack_cmd "make install"
pack_store octave.test
