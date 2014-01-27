for v in 3.2 3.4 ; do
add_package --directory llvm-$v --version $v \
    http://llvm.org/releases/$v/llvm-$v.src.tar.gz

[ "$v" == "3.2" ] && pack_set --directory llvm-$v.src

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

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
if ! $(is_host surt thul slid muspel) ; then
    pack_set --command "REQUIRES_RTTI=1 make check LIT_ARGS='-s -j2'"
fi

pack_set --command "make install"

done
