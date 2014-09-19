add_package ftp://sourceware.org/pub/libffi/libffi-3.1.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/include/ffi.h

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --install-prefix)"

if $(is_c intel) ; then
    # The __m128 is not needed anymore, the intel-tema has fixed the issue
    # i can also see that a patch has been committed to libffi
    # So for the next release this should not be necessary
    pack_set --command "sed -i -e 's:INTEL_COMPILER:INTEL_COMPILERS:' src/x86/ffi64.c"
fi

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test

flib="$(pack_get --install-prefix)/lib/libffi-$(pack_get --version)/include"
flib64="$(pack_get --install-prefix)/lib64/libffi-$(pack_get --version)/include"
tinc="$(pack_get --install-prefix)/include"

# Fix the include placement
pack_set --command "[ -d $flib ] && mv $flib $tinc || true"
pack_set --command "[ -d $flib64 ] && mv $flib $tinc || true"

# Fix pkgconfig
for f in lib lib64 ; do
    flib="$(pack_get --install-prefix)/$f/pkgconfig/libffi.pc"
    pack_set --command "[ -e $flib ] && sed -i -e 's:includedir=.*:includedir=\${prefix}/include:' $flib || true"
    flib="$(pack_get --install-prefix)/$f/libffi-$(pack_get --version)"
    pack_set --command "[ -d $flib ] && rm -rf $(pack_get --install-prefix)/lib/libffi-$(pack_get --version) || true"
done
unset flib
unset flib64
unset tinc
