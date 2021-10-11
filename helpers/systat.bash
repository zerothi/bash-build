v=12.5.4
add_package --build generic \
	    --archive sysstat-$v.tar.gz \
	    https://github.com/sysstat/sysstat/archive/refs/tags/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -prefix)/bin/pidstat

pack_cmd "./configure --disable-sensors --enable-lto --prefix=$(pack_get -prefix) --enable-install-cron"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
