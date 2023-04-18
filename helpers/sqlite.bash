v=3.41.2
dv=3410200
add_package -package sqlite -build generic -version $v \
	    http://www.sqlite.org/2023/sqlite-autoconf-$dv.tar.gz

pack_set -lib -lsqlite3
pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -prefix)/bin/sqlite3

pack_cmd "../configure --prefix $(pack_get -prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
