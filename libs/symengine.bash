v=0.10.1
add_package https://github.com/symengine/symengine/releases/download/v$v/symengine-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -build-mod-req build-tools

pack_set -install-query $(pack_get -prefix)/include/symengine/symengine_config.h
pack_set -lib -lsymengine

_tmp_flags=
function _symengine_flags {
    _tmp_flags="$_tmp_flags $@"
}

_symengine_flags -DWITH_BFD:BOOL=ON
_symengine_flags -DWITH_SYMENGINE_RCP:BOOL=ON
# Requires ECM library
#_symengine_flags -DWITH_ECM:BOOL=ON
_symengine_flags -DWITH_OPENMP:BOOL=ON
_symengine_flags -DWITH_MPFR:BOOL=ON
_symengine_flags -DWITH_MPC:BOOL=ON
_symengine_flags -DWITH_LLVM:BOOL=OFF
_symengine_flags -DINTEGER_CLASS:STRING=gmp
_symengine_flags -DBUILD_SHARED_LIBS:BOOL=ON
# Ensure using RPATH
_symengine_flags -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=ON
# Add numerical libraries
_symengine_flags -DWITH_MPC=yes
_symengine_flags -DWITH_MPFR=yes
_symengine_flags -DWITH_GMP=yes
_symengine_flags -DWITH_BFD=no

# Search for libraries etc. in this directory
_symengine_flags -DCMAKE_PREFIX_PATH=$(pack_get -prefix $(pack_get -mod-req[gcc]))

# Installation directory
_symengine_flags -DCMAKE_INSTALL_PREFIX:PATH=$(pack_get -prefix)

pack_cmd "cmake $_tmp_flags .."
pack_cmd "make $(get_make_parallel)"
pack_cmd "ctest > symengine.test 2>&1"
pack_cmd "make install"
pack_store symengine.test

unset _symengine_flags
