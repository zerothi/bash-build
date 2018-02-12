v=3.5.2
add_package --build generic \
	    --directory llvm-$v.src --package llvm --version $v \
	    http://llvm.org/releases/$v/llvm-$v.src.tar.xz

pack_set -s $IS_MODULE -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/bin/llvm-ar

pack_set $(list -p '-mod-req ' gen-zlib gen-libxml2 gen-libffi gmp)

# Create Cmake variable file
file=NPACmake.txt
pack_cmd "echo '# NPA Cmake script for LLVM' > $file"

# Fetch the c-lang to build it along side
tmp=$(pack_get --url)
for name in cfe compiler-rt openmp libcxx libcxxabi clang-tools-extra ; do
    case $name in
	cfe)
	    pack=clang
	    ;;
	clang-tools-extra)
	    pack=extra
	    ;;
	*)
	    pack=$name
	    ;;
    esac
    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-$name-$v.src.tar.xz
    dwn_file ${tmp//llvm-/$name-} $o
    case $name in
	clang-tools-extra)
	    pack_cmd "tar xfJ $o -C ../tools/clang/tools/"
	    pack_cmd "pushd ../tools/clang/tools"
	    pack_cmd "mv $name* $pack"
	    pack_cmd "popd"
	    ;;
	libcxx*|compiler-rt|dragonegg|libunwind)
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
    case $name in
	cfe)
	    #pack_cmd "tmp=\$(pwd) ; echo \"SET(LLVM_EXTERNAL_CLANG_SOURCE_DIR tools/$pack CACHE PATH $name-PATH)\" >> $file"
	    ;;
	polly)
	    #pack_cmd "tmp=\$(pwd) ; echo \"SET(LLVM_EXTERNAL_POLLY_SOURCE_DIR tools/$pack CACHE PATH $name-PATH)\" >> $file"
	    ;;
	clang-tools-extra)
	    #pack_cmd "tmp=\$(pwd) ; echo \"SET(LLVM_EXTERNAL_CLANG_TOOLS_EXTRA_SOURCE_DIR tools/clang/tools/$pack CACHE PATH $name-PATH)\" >> $file"
	    ;;
	libcxxabi)
	    #pack_cmd "echo 'SET(LLVM_ENABLE_LIBCXXABI ON CACHE STRING $name-ON)' >> $file"
	    #pack_cmd "tmp=\$(pwd) ; echo \"SET(LIBCXX_CXX_ABI_INCLUDE_PATHS \$tmp/../tools/$pack/include CACHE PATH $name-PATH)\" >> $file"
	    #pack_cmd "tmp=\$(pwd) ; echo \"SET(LIBCXX_LIBCXXABI_INCLUDES \$tmp/../tools/$pack/include CACHE PATH $name-PATH)\" >> $file"
	    ;;
	libcxx)
	    #pack_cmd "echo 'SET(LLVM_ENABLE_LIBCXX ON CACHE STRING $name-ON)' >> $file"
	    #pack_cmd "echo 'SET(LIBCXX_CXX_ABI libcxxabi CACHE STRING $name-ABI)' >> $file"
	    #pack_cmd "tmp=\$(pwd) ; echo \"SET(LIBCXXABI_LIBCXX_PATH tools/$pack/src CACHE PATH $name-PATH)\" >> $file"
	    #pack_cmd "tmp=\$(pwd) ; echo \"SET(LIBCXXABI_LIBCXX_INCLUDES \$tmp/../tools/$pack/include CACHE PATH $name-INC)\" >> $file"
	    ;;
    esac
done

opt="-DCMAKE_INSTALL_PREFIX=$(pack_get --prefix)"
opt="$opt -DCMAKE_BUILD_TYPE=Release"
opt="$opt -DLLVM_PARALLEL_COMPILE_JOBS=$NPROCS"

# Prepare Cmake setup
pack_cmd "CC=$CC CXX=$CXX cmake -G 'Unix Makefiles' $opt .."

# Make commands (this cmake --build removes colors)
pack_cmd "cmake --build . -- $(get_make_parallel)"
pack_cmd "cmake --build . --target install"

