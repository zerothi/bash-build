if [ "x${pV:0:1}" == "x3" ]; then
    v=2019.09.3
else
    v=2018.09.3
fi
add_package -package rdkit -version $v -archive rdkit-Release_${v//./_}.tar.gz \
	    https://github.com/rdkit/rdkit/archive/Release_${v//./_}.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set -module-opt "-lua-family rdkit"

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/rdkit

pack_set -build-mod-req build-tools
pack_set $(list -p '-mod-req ' boost numpy eigen)

tmp_flags="-DRDK_INSTALL_INTREE=OFF"
tmp_flags="$tmp_flags -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
tmp_flags="$tmp_flags -DBOOST_ROOT=$(pack_get -prefix boost)"
tmp_flags="$tmp_flags -DBoost_NO_SYSTEM_PATHS=ON"
tmp_flags="$tmp_flags -DRDK_BUILD_CAIRO_SUPPORT=ON"
tmp_flags="$tmp_flags -DEIGEN3_INCLUDE_DIR=$(pack_get -prefix eigen)/include"
_p=$(pack_get -prefix $(get_parent))
[ -e $_p/include/python${pV}m ] && v=${pV}m || v=${pV}
tmp_flags="$tmp_flags -DPYTHON_LIBRARY=$(pack_get -LD $(get_parent))/libpython$v.a -DPYTHON_INCLUDE_DIR=$_p/include/python$v -DPYTHON_EXECUTABLE=$(get_parent_exec)"

pack_cmd "cmake $tmp_flags .."
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"


