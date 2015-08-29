for v in 3.3 3.4 ; do
add_package --directory llvm-$v.src --package llvm --version $v \
	    http://llvm.org/releases/$v/llvm-$v.src.tar.gz

[[ "$v" == "3.4" ]] && pack_set --directory llvm-$v

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

if $(is_c intel) ; then
    pack_set --host-reject $(get_hostname)
fi

pack_set --install-query $(pack_get --prefix)/bin/llvm-ar

pack_set --module-requirement zlib \
    --module-requirement libffi

# Fetch the c-lang to build it along side
tmp=$(pack_get --url)
name=clang
if [[ $(vrs_cmp $v 3.3) -le 0 ]]; then
    name=cfe
fi
pack_cmd "wget ${tmp//llvm-/$name-}"
pack_cmd "tar xfz $name-$v.src.tar.gz -C ../tools/"
pack_cmd "pushd ../tools"
tmp=$(pack_get --directory)
pack_cmd "ln -s ${tmp//llvm-/$name-} clang"
pack_cmd "popd"

# Install commands that it should run
pack_cmd "../configure" \
	 "--enable-zlib" \
	 "--enable-libffi" \
	 "--enable-optimized" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "REQUIRES_RTTI=1 make $(get_make_parallel)"
pack_cmd "REQUIRES_RTTI=1 make check-all LIT_ARGS='-s -j2'"
pack_cmd "make install"

# Install clang together with llvm
pack_cmd "cd tools/clang"
pack_cmd "make test > tmp.test 2>&1"
pack_cmd "make install"
pack_set_mv_test tmp.test

done
