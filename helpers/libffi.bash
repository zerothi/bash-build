add_package --build generic --alias gen-libffi --package gen-libffi \
    ftp://sourceware.org/pub/libffi/libffi-3.1.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/include/ffi.h

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test

# Fix include path and pkgconfig
for f in lib lib64 ; do
    flib="$(pack_get --prefix)/$f/pkgconfig/libffi.pc"
    pack_set --command "[ -e $flib ] && sed -i -e 's:includedir=.*:includedir=\${prefix}/include:' $flib || true"
    flib="$(pack_get --prefix)/$f/libffi-$(pack_get --version)"
    pack_set --command "[ -d $flib/include ] && mv $flib/include $(pack_get --prefix)/include || true"
    pack_set --command "[ -d $flib ] && rm -rf $flib || true"
done
unset flib
unset tinc
