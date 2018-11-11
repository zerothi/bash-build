add_package https://github.com/NFFT/nfft/releases/download/3.4.1/nfft-3.4.1.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libnfft.a
pack_set --lib -lnfft

# Install commands that it should run
pack_cmd "../configure" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
