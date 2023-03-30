add_package --package osu-benchmarks \
    http://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.0.1.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR
pack_set -install-query $(pack_get -prefix)/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency

pack_set -module-requirement mpi
pack_set -module-opt "-set-ENV OSU_HOME=$(pack_get -prefix)"

pack_cmd "../configure --prefix=$(pack_get -prefix) CC=$MPICC CXX=$MPICXX FC=$MPIFC"
pack_cmd "make"
pack_cmd "make install"



