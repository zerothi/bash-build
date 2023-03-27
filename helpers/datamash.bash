add_package --build generic https://ftp.gnu.org/gnu/datamash/datamash-1.8.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR


pack_set --install-query $(pack_get --prefix)/bin/datamash

# Install commands that it should run
pack_cmd "../configure --prefix=$(pack_get --prefix)"

# Make commands
pack_cmd "make"
pack_cmd "make check > datamash.test"
pack_cmd "make install"
pack_store datamash.test
