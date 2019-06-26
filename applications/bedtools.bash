v=2.28.0
add_package -directory bedtools2 \
	    https://github.com/arq5x/bedtools2/releases/download/v$v/bedtools-$v.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/bin/bedtools

pack_set -module-opt "-lua-family bedtools"

# Install commands that it should run
pack_cmd "make CXX=$CXX CXXFLAGS='$CXXFLAGS -D_FILE_OFFSET_BITS=64 -DWITH_HTS_CB_API \$(INCLUDES)' $(get_make_parallel)"
pack_cmd "make CXX=$CXX CXXFLAGS='$CXXFLAGS -D_FILE_OFFSET_BITS=64 -DWITH_HTS_CB_API \$(INCLUDES)' test 2>&1 > bedtools.test"
pack_store bedtools.test
pack_cmd "make prefix=$(pack_get -prefix) install"
