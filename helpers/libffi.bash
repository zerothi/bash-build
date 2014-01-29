add_package --build generic --alias gen-libffi \
    ftp://sourceware.org/pub/libffi/libffi-3.0.13.tar.gz

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
pack_set --command "make" \
    --command-flag "check" \
    --command-flag "install"

# Fix the include placement
pack_set --command "mv $(pack_get --install-prefix)/lib/libffi-$(pack_get --version)/include" \
    --command-flag "$(pack_get --install-prefix)/include"
pack_set --command "rm -rf $(pack_get --install-prefix)/lib/libffi-$(pack_get --version)"
# Fix the pkgconfig
pack_set --command "sed -i -e 's:includedir=.*:includedir=\${prefix}/include:' $(pack_get --install-prefix)/lib/pkgconfig/libffi.pc"

