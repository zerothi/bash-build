v=9.2.0
add_package https://github.com/OSGeo/PROJ/releases/download/$v/proj-$v.tar.gz
pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libproj.so
pack_set -lib -lproj

pack_set $(list -p '-mod-req ' sqlite curl)

opts=
opts="$opts -DTHREADS_PREFER_PTHREAD_FLAG=TRUE"
opts="$opts -DCMAKE_C_FLAGS='$CFLAGS -pthread $(list -LD-rp sqlite) -lsqlite3'"
opts="$opts -DCMAKE_CXX_FLAGS='$CXXFLAGS -pthread'"
#opts="$opts -DSQLITE3_FOUND=TRUE"
opts="$opts -DSQLITE3_LIBRARY=$(pack_get -prefix sqlite)/lib/libsqlite3.so"
#opts="$opts -DSQLITE3_VERSION=$(pack_get -version sqlite)"
opts="$opts -DSQLITE3_INCLUDE_DIR=$(pack_get -prefix sqlite)/include"
opts="$opts -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"

pack_cmd "cmake -Bbuild-tmp -S. $opts"
pack_cmd "cmake --build build-tmp $(get_make_parallel)"
pack_cmd "pushd build-tmp ; ctest 2>&1 > ../proj.test ; popd "
pack_cmd "cmake --build build-tmp --target install"
pack_store proj.test
