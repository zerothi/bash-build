v=12.0.1
add_package -directory llvm-project-$v.src -package llvm -version $v \
	    https://github.com/llvm/llvm-project/releases/download/llvmorg-$v/llvm-project-$v.src.tar.xz

pack_set -s $IS_MODULE -s $BUILD_DIR -s $MAKE_PARALLEL -s $CRT_DEF_MODULE
#pack_set -s $IS_MODULE -s $BUILD_DIR -s $CRT_DEF_MODULE

pack_set -install-query $(pack_get -prefix)/bin/llvm-ar

pack_set $(list -p '-build-mod-req ' build-tools gcc)
pack_set $(list -p '-mod-req ' gen-zlib gen-libxml2 gen-libffi)

opt="-DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
opt="$opt -DCMAKE_BUILD_TYPE=Release"
opt="$opt -DCMAKE_CXX_LINK_FLAGS='$(list -LD-rp gcc)'"
opt="$opt -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra;compiler-rt;libcxx;libclc;libcxxabi;lld;lldb;openmp;polly;parallel-libs;flang'"
opt="$opt -DLLVM_PARALLEL_COMPILE_JOBS=$NPROCS"
opt="$opt -DLLVM_BINUTILS_INCDIR=$(pack_get -prefix build-tools)/include"

# add include limits
pack_cmd "sed -i '/#include <vector>/i #include <limits>' ../llvm/utils/benchmark/src/benchmark_register.h"

# Prepare Cmake setup
pack_cmd "CC=$CC CXX=$CXX cmake -G 'Ninja' $opt ../llvm"

# Make commands (this cmake --build removes colors)
pack_cmd "cmake --build . -- $(get_make_parallel) "
pack_cmd "cmake --build . --target install"

source compiler/llvm/llvm-env.bash
