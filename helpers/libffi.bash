add_package --build generic --alias gen-libffi --package gen-libffi \
    ftp://sourceware.org/pub/libffi/libffi-3.0.13.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/include/ffi.h

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"

pack_set --command "mv tmp.test $(pack_get --install-prefix)/"

# Fix the include placement
pack_set --command "mv $(pack_get --install-prefix)/lib/libffi-$(pack_get --version)/include" \
    --command-flag "$(pack_get --install-prefix)/include"
pack_set --command "rm -rf $(pack_get --install-prefix)/lib/libffi-$(pack_get --version)"
# Fix the pkgconfig
pack_set --command "sed -i -e 's:includedir=.*:includedir=\${prefix}/include:' $(pack_get --install-prefix)/lib/pkgconfig/libffi.pc"
pack_set --command "cd $(pack_get --install-prefix)"
pack_set --command "if test -d lib64 ; then mv lib64/* lib/ ; fi"
pack_set --command "if test -d lib64 ; then rm -rf lib64 ; fi"

