add_package https://bitbucket.org/berkeleylab/upcxx/downloads/upcxx-2022.9.0.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# What to check for when checking for installation...
pack_set -install-query $(pack_get -prefix)/bin/upcxx

pack_set -build-mod-req build-tools
pack_set -mod-req numactl
pack_set -mod-req mpi
pack_set -mod-req ucx

# Install commands that it should run
opt=
if ! $(is_host nicpa) ; then
	opt="$opt --enable-ofi"
fi

pack_cmd "../configure --with-cxx=$MPICXX --enable-ucx $opt --prefix=$(pack_get -prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check NETWORK=smp > upcxx.test 2>&1 || echo forced"
pack_store upcxx.test
pack_cmd "make install"
