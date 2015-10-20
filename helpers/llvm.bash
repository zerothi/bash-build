for v in 3.7.0 ; do
add_package --build generic \
	    --directory llvm-$v.src --package llvm --version $v \
	    http://llvm.org/releases/$v/llvm-$v.src.tar.xz

pack_set -s $IS_MODULE -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/bin/llvm-ar

pack_set --host-reject $(get_hostname)

pack_set $(list -p '-mod-req ' gen-zlib gen-libxml2 gen-libffi cloog gmp)

# Create Cmake variable file
file=NPACmake.txt
pack_cmd "echo '# NPA Cmake script for LLVM' > $file"

# Fetch the c-lang to build it along side
tmp=$(pack_get --url)
for name in cfe compiler-rt polly openmp libcxx libcxxabi clang-tools-extra ; do
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
	    pack_cmd "echo 'SET(LLVM_ENABLE_LIBCXXABI ON CACHE STRING $name-ON)' >> $file"
	    #pack_cmd "tmp=\$(pwd) ; echo \"SET(LIBCXX_CXX_ABI_INCLUDE_PATHS \$tmp/../tools/$pack/include CACHE PATH $name-PATH)\" >> $file"
	    #pack_cmd "tmp=\$(pwd) ; echo \"SET(LIBCXX_LIBCXXABI_INCLUDES \$tmp/../tools/$pack/include CACHE PATH $name-PATH)\" >> $file"
	    ;;
	libcxx)
	    pack_cmd "echo 'SET(LLVM_ENABLE_LIBCXX ON CACHE STRING $name-ON)' >> $file"
	    #pack_cmd "echo 'SET(LIBCXX_CXX_ABI libcxxabi CACHE STRING $name-ABI)' >> $file"
	    #pack_cmd "tmp=\$(pwd) ; echo \"SET(LIBCXXABI_LIBCXX_PATH tools/$pack/src CACHE PATH $name-PATH)\" >> $file"
	    #pack_cmd "tmp=\$(pwd) ; echo \"SET(LIBCXXABI_LIBCXX_INCLUDES \$tmp/../tools/$pack/include CACHE PATH $name-INC)\" >> $file"
	    ;;
    esac
done

# Add a new line
pack_cmd "echo '' >> $file"

pack_cmd "sed -i -e '$ a\
SET(CMAKE_INSTALL_PREFIX $(pack_get --prefix) CACHE PATH PATH)\n\
SET(CMAKE_C_FLAGS \"$CFLAGS\" CACHE STRING CFLAGS)\n\
SET(CMAKE_CXX_FLAGS \"$CXXFLAGS\" CACHE STRING CXXFLAGS)\n\
\n\
SET(CMAKE_LIBRARY_PATH \${CMAKE_LIBRARY_PATH} $(list -c 'pack_get --library-path' $(pack_get --mod-req)) CACHE PATH LPATH)\n\
SET(CMAKE_SKIP_BUILD_RPATH  FALSE CACHE BOOLEAN Build-rpath)\n\
SET(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE CACHE BOOLEAN Install-rpath)\n\
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE CACHE BOOLEAN Link-rpath)\n\
SET(CMAKE_INSTALL_RPATH \${CMAKE_LIBRARY_PATH} \${CMAKE_INSTALL_PREFIX}/lib $(list -c 'pack_get --library-path' $(pack_get --mod-req)) CACHE PATH R-paths)\n\
\n\
foreach(TMPDIR $(list -c 'pack_get --prefix ' -s '/include ' $(pack_get --mod-req)))\n\
SET(INCLUDE_DIRECTORIES \${INCLUDE_DIRECTORIES} \${TMPDIR})\n\
endforeach(TMPDIR)\n\
\n\
SET(LLVM_ENABLE_PIC ON CACHE BOOLEAN Enable-pic)\n\
SET(LLVM_PARALLEL_COMPILE_JOBS $NPROCS CACHE STRING NPROCS)\n\
SET(LLVM_ENABLE_RTTI ON CACHE BOOLEAN RTTI)\n\
\n\
SET(LLVM_LIT_ARGS \"-s -j2\" CACHE STRING LIT-args)\n\
SET(LLVM_ENABLE_FFI ON CACHE BOOLEAN Enable-FFI)\n\
SET(FFI_INCLUDE_DIR $(pack_get --prefix gen-libffi)/include CACHE PATH FFI-inc-dir)\n\
SET(FFI_LIBRARY_DIR $(pack_get -L gen-libffi) CACHE PATH FFI-lib-dir)\n\
SET(LLVM_ENABLE_ZLIB ON CACHE BOOLEAN Enable-zlib)\n\
SET(ZLIB_INCLUDE_DIR $(pack_get --prefix gen-zlib)/include CACHE PATH zlib-inc-dir)\n\
SET(ZLIB_LIBRARY_DIR $(pack_get -L gen-zlib) CACHE PATH zlib-lib-dir)\n\
\n\
SET(LIBXML2_INCLUDE_DIR $(pack_get --prefix gen-libxml2)/include CACHE PATH libxml2-inc-dir)\n\
#FIND_LIBRARY(LIBXML2_LIBRARY xml2 $(pack_get --LD gen-libxml2))\n\
SET(LIBXML2_LIBRARIES $(pack_get --LD gen-libxml2)/libxml2.so CACHE FILEPATH libxml2-library)\n\
\n\
SET(CLOOG_INCLUDE_DIR $(pack_get --prefix cloog)/include CACHE PATH cloog-inc-dir)\n\
\n\
SET(GMP_INCLUDE_DIR $(pack_get --prefix gmp)/include CACHE PATH gmp-inc-dir)\n\
SET(GMP_LIBRARY $(pack_get --LD gmp)/libgmp.a CACHE FILEPATH gmp-library)\n\
\n\
SET(ISL_INCLUDE_DIR $(pack_get --prefix isl)/include CACHE PATH isl-inc-dir)\n\
SET(ISL_LIBRARY $(pack_get --LD isl)/libisl.a CACHE FILEPATH isl-library)\n\
SET(BUILD_SHARED_LIBS ON CACHE BOOL)\n\
' $file"

# Install commands that it should run
pack_cmd "module load cmake"

# Prepare Cmake setup
pack_cmd "cmake -C $file .."

# Make commands (this cmake --build removes colors)
pack_cmd "cmake --build . -- $(get_make_parallel)"
pack_cmd "cmake --build . --target install"

pack_cmd "module unload cmake"

done
