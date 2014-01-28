for v in 3.3 3.4 ; do
add_package --directory llvm-$v.src --package llvm --version $v \
    http://llvm.org/releases/$v/llvm-$v.src.tar.gz

[ "$v" == "3.4" ] && pack_set --directory llvm-$v

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

if $(is_c intel) ; then
    pack_set --host-reject $(hostname)
fi

pack_set --install-query $(pack_get --install-prefix)/bin/llvm-ar

pack_set --module-requirement zlib \
    --module-requirement libffi

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--enable-zlib" \
    --command-flag "--enable-libffi" \
    --command-flag "--enable-optimized" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "REQUIRES_RTTI=1 make $(get_make_parallel)"
pack_set --command "REQUIRES_RTTI=1 make check-all LIT_ARGS='-s -j2'"

pack_set --command "make install"

done
