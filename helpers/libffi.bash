v=3.4.4
add_package -build generic -alias gen-libffi -package gen-libffi \
	    https://github.com/libffi/libffi/releases/download/v$v/libffi-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -prefix)/include/ffi.h

# Install commands that it should run
pack_cmd "./configure --prefix $(pack_get -prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
if $(is_host slid muspel surt) ; then
    echo "Do nothing" > /dev/null
else
    pack_cmd "make check > libffi.test 2>&1"
    pack_store libffi.test
fi
pack_cmd "make install"

# Fix include path and pkgconfig
for f in lib lib64 ; do
    flib="$(pack_get -prefix)/$f/pkgconfig/libffi.pc"
    pack_cmd "[ -e $flib ] && sed -i -e 's:includedir=.*:includedir=\${prefix}/include:' $flib || true"
    flib="$(pack_get -prefix)/$f/libffi-$(pack_get -version)"
    pack_cmd "[ -d $flib/include ] && mv $flib/include $(pack_get -prefix)/include || true"
    pack_cmd "[ -d $flib ] && rm -rf $flib || true"
done
unset flib
unset tinc
