v=11.1.0
add_package -directory llvm-$v.src -package llvm -version $v \
	    https://github.com/llvm/llvm-project/releases/download/llvmorg-$v/llvm-$v.src.tar.xz

pack_set -s $IS_MODULE -s $BUILD_DIR -s $MAKE_PARALLEL -s $CRT_DEF_MODULE

pack_set -install-query $(pack_get -prefix)/bin/llvm-ar

pack_set $(list -p '-build-mod-req ' build-tools gcc)
pack_set $(list -p '-mod-req ' gen-zlib gen-libxml2 gen-libffi gcc)

# Fetch the c-lang to build it along side
tmp=$(pack_get -url)
for name in clang compiler-rt libcxx libcxxabi libunwind lld lldb openmp polly flang clang-tools-extra ; do
    case $name in
	lldb|lld|clang-tools-extra)
	    # Skipped packages
	    continue
	    ;;
	clang-tools-extra)
	    pack=extra
	    ;;
	*)
	    pack=$name
	    ;;
    esac
    o=$(pwd_archives)/$(pack_get -package)-$(pack_get -version)-$name-$v.src.tar.xz
    dwn_file ${tmp//$v\/llvm-/$v\/$name-} $o
    case $name in
	clang|clang-tools-extra)
	    pack_cmd "tar xfJ $o -C ../tools/"
	    pack_cmd "pushd ../tools"
	    pack_cmd "mv $name* $pack"
	    pack_cmd "popd"
	    ;;
	compiler-rt|libcxx*|libunwind|dragonegg|openmp)
	    pack_cmd "tar xfJ $o -C ../projects/"
	    pack_cmd "pushd ../projects"
	    pack_cmd "mv $name* $pack"
	    pack_cmd "popd"
	    ;;
	*)
	    pack_cmd "tar xfJ $o -C ../tools/"
	    pack_cmd "pushd ../tools"
	    pack_cmd "mv $name* $pack"
	    pack_cmd "popd"
	    ;;
    esac
done

opt="-DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
opt="$opt -DCMAKE_BUILD_TYPE=Release"
opt="$opt -DLLVM_PARALLEL_COMPILE_JOBS=$NPROCS"
opt="$opt -DLLVM_BINUTILS_INCDIR=$(pack_get -prefix build-tools)/include"

# Prepare Cmake setup
pack_cmd "CC=$CC CXX=$CXX cmake -G 'Unix Makefiles' $opt .."

# Make commands (this cmake --build removes colors)
pack_cmd "cmake --build . -- $(get_make_parallel)"
pack_cmd "cmake --build . --target install"

source compiler/llvm/llvm-env.bash
