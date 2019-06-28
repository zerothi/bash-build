v=2.28.0
add_package -directory bedtools2 \
	    https://github.com/arq5x/bedtools2/releases/download/v$v/bedtools-$v.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/bin/bedtools

pack_set -module-opt "-lua-family bedtools"

# Install commands that it should run
# Clean weird files!
tmp_flags='VERBOSE=1 CXX=$CXX CC=$CC'
if [[ $(vrs_cmp $(pack_get -version) 2.28.0) -le 0 ]]; then
    pack_cmd "rm gcc g++"
    pack_cmd "sed -i -e 's/CXXFLAGS =.*/CXXFLAGS = $CXXFLAGS -D_FILE_OFFSET_BITS=64 -DWITH_HTS_CB_API \$(INCLUDES)/' Makefile"
else
    tmp_flags="$tmp_flags CXXFLAGS='$CXXFLAGS'"
fi
pack_cmd "make $tmp_flags $(get_make_parallel)"
pack_cmd "make $tmp_flags test 2>&1 > bedtools.test ; echo forced"
pack_store bedtools.test
pack_cmd "make $tmp_flags prefix=$(pack_get -prefix) install"
