for v in 3.3 3.4 ; do
add_package --directory llvm-$v.src --package llvm --version $v \
    http://llvm.org/releases/$v/llvm-$v.src.tar.gz

[ "$v" == "3.4" ] && pack_set --directory llvm-$v

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

if $(is_c intel) ; then
    pack_set --host-reject $(hostname)
fi

pack_set --install-query $(pack_get --install-prefix)/bin/llvm-ar

pack_set --module-requirement gen-zlib \
    --module-requirement gen-libffi

# Fetch the c-lang to build it along side
tmp=$(pack_get --url)
name=clang
if [ $(vrs_cmp $v 3.3) -le 0 ]; then
    name=cfe
fi
pack_set --command "wget ${tmp//llvm-/$name-}"
pack_set --command "tar xfz $name-$v.src.tar.gz -C ../tools/"
pack_set --command "pushd ../tools"
tmp=$(pack_get --directory)
pack_set --command "ln -s ${tmp//llvm-/$name-} clang"
pack_set --command "popd"

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--enable-zlib" \
    --command-flag "--enable-libffi" \
    --command-flag "--enable-optimized" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "REQUIRES_RTTI=1 make $(get_make_parallel)"
pack_set --command "REQUIRES_RTTI=1 make check-all LIT_ARGS='-s -j2'"
pack_set --command "make install"

# Install clang together with llvm
pack_set --command "cd tools/clang"
pack_set --command "make test"
pack_set --command "make install"

done
