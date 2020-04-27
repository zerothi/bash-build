v=1.7.0
add_package https://github.com/NanoComp/mpb/releases/download/v$v/mpb-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/bin/mpbi-mpi

pack_set -module-opt "--lua-family mpb"

pack_set -module-requirement mpi \
	 -module-requirement libctl \
	 -module-requirement zlib \
	 -module-requirement hdf5 \
	 -module-requirement fftw-mpi

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
tmp="$tmp --with-libctl=$(pack_get --prefix libctl)/share/libctl"

# Install commands that it should run
pack_cmd "../configure" \
     "GEN_CTL_IO=$(pack_get --prefix libctl)/bin/gen-ctl-io CC='$MPICC' CXX='$MPICXX'" \
     "LDFLAGS='$(list --LD-rp $(pack_get --mod-req-path))'" \
     "CPPFLAGS='$(list --INCDIRS $(pack_get --mod-req-path))'" \
     "--with-mpi" \
     "--prefix=$(pack_get --prefix) $tmp" 
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

# Install the inversion symmetric part
pack_cmd "make distclean"
pack_cmd "../configure" \
     "GEN_CTL_IO=$(pack_get --prefix libctl)/bin/gen-ctl-io CC='$MPICC' CXX='$MPICXX'" \
     "LDFLAGS='$(list --LD-rp $(pack_get --mod-req-path))'" \
     "CPPFLAGS='$(list --INCDIRS $(pack_get --mod-req-path))'" \
     "--with-mpi --with-inv-symmetry" \
     "--prefix=$(pack_get --prefix) $tmp" 
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
