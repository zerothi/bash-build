v=16.0.6
add_package -directory llvm-project-$v.src -package llvm -version $v \
	    https://github.com/llvm/llvm-project/releases/download/llvmorg-$v/llvm-project-$v.src.tar.xz

pack_set -s $IS_MODULE -s $CRT_DEF_MODULE -s $MAKE_PARALLEL -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -prefix)/bin/flang-new

pack_set $(list -p '-build-mod-req ' build-tools)
pack_set $(list -p '-mod-req ' gcc[$gnu_v])
pack_set $(list -p '-mod-req ' gen-zlib gen-libxml2 gen-libffi)

opt="-DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
opt="$opt -DGCC_INSTALL_PREFIX=$(pack_get -prefix gcc[$gnu_v])"
opt="$opt -DCMAKE_BUILD_TYPE=Release"
#opt="$opt -DLIBUNWIND_USE_COMPILER_RT=ON"
opt="$opt -DLIBCXXABI_USE_LLVM_UNWINDER=YES"
#opt="$opt -DLIBCXXABI_USE_COMPILER_RT=YES"
#opt="$opt -DLIBCXX_USE_COMPILER_RT=YES"
opt="$opt -DLIBCXX_CXX_ABI=libcxxabi"
opt="$opt -DLLVM_ENABLE_RTTI=ON"
opt="$opt -DLLVM_ENABLE_EH=ON"
opt="$opt -DLLVM_ENABLE_FFI=ON"
opt="$opt -DFFI_INCLUDE_DIR=$(pack_get -prefix gen-libffi)/include"
opt="$opt -DFFI_LIBRARY_DIR=$(pack_get -LD gen-libffi)"
opt="$opt -DLIBOMP_FORTRAN_MODULES=ON"
# To disable parallel build, comment this out:
opt="$opt -DLLVM_PARALLEL_LINK_JOBS=1"
opt="$opt -DLLVM_PARALLEL_COMPILE_JOBS=$(get_parallel)"
# We have gold linker
opt="$opt -DLLVM_USE_LINKER=gold"
opt="$opt -DLLVM_BINUTILS_INCDIR=$(pack_get -prefix build-tools)/include"
if $(is_host n-) ; then
    opt="$opt -DLLDB_ENABLE_PYTHON=OFF"
fi

opt="$opt -DLLVM_ENABLE_RUNTIMES='compiler-rt;libcxx;libcxxabi;libunwind'"
opt="$opt -DCMAKE_C_COMPILER='$CC'"
opt="$opt -DCMAKE_CXX_COMPILER='$CXX'"
opt="$opt -DCMAKE_CXX_LINK_FLAGS='$(list -LD-rp $(pack_get -mod-req))'"
opt="$opt -DCMAKE_CXX_FLAGS='$CXXFLAGS -flarge-source-files'"

add_opt="$opt -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra;libclc;lld;lldb;openmp;polly;pstl;mlir'"
pack_cmd "cmake -G 'Ninja' $add_opt -B build-clang ./llvm"
pack_cmd "echo 'stage-1' ; cmake --build build-clang $(get_make_parallel)"
add_opt="$opt -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra;libclc;lld;lldb;openmp;polly;pstl;mlir;flang'"
pack_cmd "cmake -G 'Ninja' $add_opt -B build-clang ./llvm"
pack_cmd "echo 'stage-2' ; cmake --build build-clang -j 2 -t flang-new"
pack_cmd "echo 'stage-3' ; cmake --build build-clang --target install"


source compiler/llvm/llvm-env.bash
