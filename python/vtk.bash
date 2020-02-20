add_package -package vtk https://www.vtk.org/files/release/8.2/VTK-8.2.0.tar.gz

pack_set -install-query $(pack_get -prefix)/bin/vtkpython

pack_set -s $IS_MODULE -s $BUILD_DIR -s $MAKE_PARALLEL -s $PRELOAD_MODULE

pack_set -module-opt "-lua-family vtk"
pack_set -module-opt "-ld-library-path"

pack_set -module-requirement numpy
pack_set -module-requirement mpi4py

pack_cmd "mkdir -p $(pack_get -prefix)/lib/python$pV/site-packages/"

pack_cmd "cmake -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix) -DVTK_WRAP_PYTHON=1" \
	 -DPYTHON_EXECUTABLE=$(pack_get -prefix $(get_parent))/bin/python3 \
	 -DVTK_PYTHON_VERSION=$pV ..

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
