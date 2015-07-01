for v in 3.6.0 ; do
add_package --build generic \
    --directory llvm-$v.src --package llvm --version $v \
    http://llvm.org/releases/$v/llvm-$v.src.tar.xz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --prefix)/bin/llvm-ar

pack_set $(list -p '-mod-req ' gen-libxml2 gen-libffi cloog gmp)

# Create Cmake variable file
file=NPACmake.txt
pack_set --command "echo '# NPA Cmake script for LLVM' > $file"

# Fetch the c-lang to build it along side
tmp=$(pack_get --url)
for name in cfe lld clang-tools-extra dragonegg ; do
    pack=$name
    [ "x$name" == "xcfe" ] && pack=clang
    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-$name-$v.src.tar.xz
    mywget ${tmp//llvm-/$name-} $o
    pack_set --command "tar xfJ $o -C ../tools/"
    pack_set --command "pushd ../tools"
    pack_set --command "mv $name* $pack"
    pack_set --command "popd"
    #if [ "x$name" == "xdragonegg" ]; then
	#pack_set --command "echo 'SET(LLVM_EXTERNAL_DRAGONEGG_SOURCE_DIR ../tools/$name CACHE PATH $name-PATH)' >> $file"
    #fi
    if [ "x$name" == "xclang-tools-extra" ]; then
	pack_set --command "echo 'SET(LLVM_EXTERNAL_CLANG_TOOLS_EXTRA_SOURCE_DIR ../../tools/$name CACHE PATH $name-PATH)' >> $file"
    fi
	

done
# Add a new line
pack_set --command "echo '' >> $file"

pack_set --command "sed -i -e '$ a\
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
#FIND_LIBRARY(ISL_LIBRARY isl $(pack_get --LD isl))\n\
#SET(ISL_LIBRARY \${ISL_LIBRARY} CACHE FILEPATH isl-library)\n\
' $file"

# Install commands that it should run
pack_set --command "module load cmake"

# Prepare Cmake setup
pack_set --command "cmake -C $file .."

# Make commands (this cmake --build removes colors)
pack_set --command "cmake --build . -- $(get_make_parallel)"
pack_set --command "cmake --build . --target check-all > tmp.test 2>&1 && echo Success > /dev/null || echo Failure > /dev/null"
pack_set --command "cmake --build . --target install"
pack_set_mv_test tmp.test

pack_set --command "module unload cmake"

done
