v=3.5.2
add_package https://github.com/NFFT/nfft/releases/download/$v/nfft-$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --module-requirement fftw
pack_set --install-query $(pack_get --LD)/libnfft3.a
pack_set --lib -lnfft

tmp_LIBS="$(list --LD-rp fftw) $(pack_get --lib[omp] fftw) $FLAG_OMP"

pack_cmd "../configure LIBS='$tmp_LIBS' CFLAGS='$CFLAGS $FLAG_OMP'" \
	 "--enable-openmp" \
	 "--enable-nfct" \
	 "--enable-nfst" \
	 "--enable-nfsft" \
	 "--enable-nfsoft" \
	 "--enable-nnfft" \
	 "--enable-nsfft" \
	 "--enable-fpt" \
	 "--with-fftw3=$(pack_get --prefix fftw)" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > nfft.test 2>&1 || echo 'forced'"
pack_store nfft.test
pack_cmd "make install"
