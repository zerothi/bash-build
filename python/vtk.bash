v=9.1.0
add_package -package vtk https://www.vtk.org/files/release/${v:0:3}/VTK-$v.tar.gz

pack_set -install-query $(pack_get -prefix)/bin/vtkpython

pack_set -s $IS_MODULE -s $BUILD_DIR -s $MAKE_PARALLEL -s $PRELOAD_MODULE

pack_set -module-opt "-lua-family vtk"
pack_set -module-opt "-ld-library-path"

if [[ $(vrs_cmp $pV 3.5) -lt 0 ]]; then
    pack_set -host-reject $(get_hostname)
fi

pack_set $(list -p '-mod-req ' numpy mpi4py)

pack_cmd "mkdir -p $(pack_get -prefix)/lib/python$pV/site-packages/"

pack_cmd "cmake -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix) -DVTK_WRAP_PYTHON=1" \
	 -DPYTHON_EXECUTABLE=$(pack_get -prefix $(get_parent))/bin/python3 \
	 -DVTK_PYTHON_VERSION=${pV:0:1} ..

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
