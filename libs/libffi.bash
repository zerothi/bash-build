add_package ftp://sourceware.org/pub/libffi/libffi-3.2.1.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -prefix)/include/ffi.h
pack_set -lib -lffi

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix $(pack_get -prefix)"

#if $(is_c intel) ; then
    # The __m128 is not needed anymore, the intel-team has fixed the issue
    # i can also see that a patch has been committed to libffi
    # So for the next release this should not be necessary
    #pack_cmd "sed -i -e 's:INTEL_COMPILER:INTEL_COMPILERS:' src/x86/ffi64.c"
#fi

# Make commands
pack_cmd "make $(get_make_parallel)"
if $(is_host slid muspel surt) ; then
    echo "Do not test" > /dev/null
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

# Install to correct library directory.
pack_install
if [[ -d $(pack_get -prefix)/lib64 ]]; then
    pack_set -library-suffix lib64
fi
