add_package https://bitbucket.org/berkeleylab/upcxx/downloads/upcxx-2020.3.2.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# What to check for when checking for installation...
pack_set -install-query $(pack_get -prefix)/bin/upcxx

pack_set -build-mod-req build-tools
pack_set -mod-req numactl
pack_set -mod-req mpi

# Install commands that it should run
pack_cmd "../configure --prefix=$(pack_get -prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > upcxx.test 2>&1 || echo forced"
pack_store upcxx.test
pack_cmd "make install"
