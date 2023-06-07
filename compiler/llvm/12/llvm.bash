v=12.0.1
add_package -directory llvm-project-$v.src -package llvm -version $v \
	    https://github.com/llvm/llvm-project/releases/download/llvmorg-$v/llvm-project-$v.src.tar.xz

pack_set -s $IS_MODULE -s $BUILD_DIR -s $CRT_DEF_MODULE -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/bin/llvm-ar

pack_set $(list -p '-build-mod-req ' build-tools gcc[$gnu_v])
pack_set $(list -p '-mod-req ' gen-zlib gen-libxml2 gen-libffi)

opt="-DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
opt="$opt -DCMAKE_BUILD_TYPE=Release"
opt="$opt -DCMAKE_CXX_LINK_FLAGS='$(list -LD-rp gcc)'"
opt="$opt -DCLANG_DEFAULT_CXX_STDLIB=libc++"
opt="$opt -DCLANG_DEFAULT_RTLIB=compiler-rt"
opt="$opt -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra;compiler-rt;libcxx;libclc;libcxxabi;lld;lldb;openmp;polly;parallel-libs;flang'"
## To disable parallel build, comment this out:
#opt="$opt -DLLVM_PARALLEL_LINK_JOBS=1"
#opt="$opt -DLLVM_PARALLEL_COMPILE_JOBS=2"
# We have gold linker
opt="$opt -DLLVM_USE_LINKER=gold"
opt="$opt -DLLVM_BINUTILS_INCDIR=$(pack_get -prefix build-tools)/include"
if $(is_host n-) ; then
    opt="$opt -DLLDB_ENABLE_PYTHON=OFF"
fi

pack_cmd "sed -i -e '/#include <cstdio>/a #include <limits>' ../flang/runtime/unit.cpp"

# Prepare Cmake setup
pack_cmd "CC=$CC CXX=$CXX cmake -G 'Ninja' $opt ../llvm"

# Make commands (this cmake --build removes colors)
for t in clang compiler-rt llc lld lldb lli omp
do
	pack_cmd "cmake --build . $(get_make_parallel) -t $t"
done
pack_cmd "cmake --build . -j 1 -t f18"
pack_cmd "cmake --build ."
pack_cmd "cmake --build . --target install"

source compiler/llvm/llvm-env.bash
