add_package --package ffi \
    ftp://sourceware.org/pub/libffi/libffi-3.0.13.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libffi.a

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

