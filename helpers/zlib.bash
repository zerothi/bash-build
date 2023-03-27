# First install zlib, which is a simple library
v=2.0.7
add_package -build generic -package gen-zlib -archive zlib-ng-$v.tar.gz \
	https://github.com/zlib-ng/zlib-ng/archive/refs/tags/$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libz.a

# Install commands that it should run
pack_cmd "./configure" \
	 --zlib-compat --64 \
	 "--prefix $(pack_get -prefix)" \
	 "--static"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > zlib.test 2>&1"
pack_cmd "make install"
pack_store zlib.test
