add_package https://github.com/NFFT/nfft/releases/download/3.4.1/nfft-3.4.1.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --module-requirement fftw-3
pack_set --install-query $(pack_get --LD)/libnfft3.a
pack_set --lib -lnfft

pack_cmd "../configure" \
	 "--enable-nfct" \
	 "--enable-nfst" \
	 "--enable-nfsft" \
	 "--enable-nfsoft" \
	 "--enable-nnfft" \
	 "--enable-nsfft" \
	 "--enable-fpt" \
	 "--with-fftw3=$(pack_get --prefix fftw-3)" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
