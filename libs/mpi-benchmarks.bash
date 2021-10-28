v=2021.3
add_package -package imb -version $v \
	    -directory mpi-benchmarks-IMB-v$v \
	    https://github.com/intel/mpi-benchmarks/archive/IMB-v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -module-requirement mpi

pack_set -install-query $(pack_get -prefix)/bin/IMB-MPI1

pack_cmd "CC=$MPICC CXX=$MPICXX make"
pack_cmd "mkdir -p $(pack_get -prefix)/bin"
pack_cmd "cp IMB-* $(pack_get -prefix)/bin/"


