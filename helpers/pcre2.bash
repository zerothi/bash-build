add_package --build generic https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.42/pcre2-10.42.tar.bz2

pack_set --host-reject ntch-2857

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/pcre2grep

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix $(pack_get --prefix)" \
	 "--enable-utf" \
	 "--disable-cpp"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
