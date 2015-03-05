for v in 3.3 ; do # 3.4.2
add_package --build generic \
    --directory llvm-$v.src --package llvm --version $v \
    http://llvm.org/releases/$v/llvm-$v.src.tar.gz

[ "$v" == "3.4" ] && pack_set --directory llvm-$v

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR
pack_set --host-reject ntch

if $(is_c intel) ; then
    pack_set --host-reject $(hostname)
fi
pack_set $(list --prefix "--host-reject " hemera eris ponto surt slid muspel)

pack_set --install-query $(pack_get --prefix)/bin/llvm-ar

pack_set --module-requirement gen-zlib \
    --module-requirement gen-libffi

# Fetch the c-lang to build it along side
tmp=$(pack_get --url)
name=clang
if [ $(vrs_cmp $v 3.3) -le 0 ]; then
    name=cfe
fi
o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-$name-$v.src.tar.gz
mywget ${tmp//llvm-/$name-} $o

pack_set --command "tar xfz $o -C ../tools/"
pack_set --command "pushd ../tools"
tmp=$(pack_get --directory)
pack_set --command "ln -s ${tmp//llvm-/$name-} clang"
pack_set --command "popd"

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--enable-zlib" \
    --command-flag "--enable-libffi" \
    --command-flag "--enable-optimized" \
    --command-flag "--prefix $(pack_get --prefix)"

# Make commands
pack_set --command "REQUIRES_RTTI=1 make $(get_make_parallel)"
pack_set --command "REQUIRES_RTTI=1 make check-all LIT_ARGS='-s -j2' > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test

done
