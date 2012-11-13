# Install
tmp="$(hostname)"
[ "${tmp:0:2}" != "n-" ] && return 0

add_package http://ab-initio.mit.edu/meep/meep-1.2.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/meep-mpi

pack_set --module-requirement openmpi \
    --module-requirement zlib \
    --module-requirement hdf5 \
    --module-requirement fftw-2 \
    --module-requirement libctl

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
fi
pack_set --module-requirement harminv
tmp="$tmp --with-libctl=$(pack_get --install-prefix libctl)/share/libctl"

tmp_ld=""
tmp_cpp=""
for cmd in $(pack_get --module-requirement) ; do
    tmp_ld="$tmp_ld -L$(pack_get --install-prefix $cmd)/lib"
    tmp_cpp="$tmp_cpp -I$(pack_get --install-prefix $cmd)/include"
done

# Install commands that it should run
pack_set --command "autoconf configure.ac > configure"
pack_set --command "./configure" \
    --command-flag "CC='$MPICC' CXX='$MPICXX'" \
    --command-flag "LDFLAGS='$tmp_ld'" \
    --command-flag "CPPFLAGS='-DH5_USE_16_API=1 $tmp_cpp'" \
    --command-flag "--with-mpi" \
    --command-flag "--prefix=$(pack_get --install-prefix) $tmp" 

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

pack_install

