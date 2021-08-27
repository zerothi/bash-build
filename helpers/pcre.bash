add_package --build generic ftp://ftp.pcre.org/pub/pcre/pcre-8.44.tar.bz2

pack_set --host-reject ntch-2857

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/pcregrep

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix $(pack_get --prefix)" \
	 "--enable-utf" \
	 "--disable-cpp"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
