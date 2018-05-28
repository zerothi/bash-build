add_package --package vtk https://www.vtk.org/files/release/8.1/VTK-8.1.1.tar.gz

pack_set --install-query $(pack_get --prefix)/bin/vtk

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set --module-opt "--lua-family vtk"

pack_cmd "cmake -DCMAKE_INSTALL_PREFIX=$(pack_get --prefix) .."

# Install commands that it should run
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
pack_cmd "oeasuthoasu"
