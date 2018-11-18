add_package https://github.com/stevengj/meep/releases/download/v1.6.0/meep-1.6.tar.gz

pack_set --install-query $(pack_get --prefix)/bin/meep-mpi

pack_set --module-opt "--lua-family meep"

pack_set --module-requirement mpi \
    --module-requirement zlib \
    --module-requirement hdf5 \
    --module-requirement libctl \
    --module-requirement fftw-mpi

# Check for Intel MKL or not
tmp=
if $(is_c intel) ; then
    tmp="--with-blas='$MKL_LIB -mkl=sequential -lmkl_blas95_lp64'"
    tmp="$tmp --with-lapack='$MKL_LIB -mkl=sequential -lmkl_lapack95_lp64'"

elif $(is_c gnu) ; then

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp_ld="$(list --LD-rp +$la)"
    tmp="$tmp --with-lapack='$tmp_ld $(pack_get -lib $la)'"
    tmp="$tmp --with-blas='$tmp_ld $(pack_get -lib $la)'"

else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi
pack_set --module-requirement harminv
tmp="$tmp --with-libctl=$(pack_get --prefix libctl)/share/libctl"

pack_cmd "module load build-tools"

# Install commands that it should run
pack_cmd "autoconf configure.ac > configure"
pack_cmd "./configure" \
     "CC='$MPICC' CXX='$MPICXX'" \
     "LDFLAGS='$(list --LD-rp $(pack_get --mod-req-path))'" \
     "CPPFLAGS='-DH5_USE_16_API=1 $(list --INCDIRS $(pack_get --mod-req-path))'" \
     "--with-mpi" \
     "--prefix=$(pack_get --prefix) $tmp" 

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

pack_cmd "module unload build-tools"
