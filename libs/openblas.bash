for v in 0.2.10 ; do
add_package --package openblas --archive OpenBLAS-$v.tar.gz \
    https://github.com/xianyi/OpenBLAS/archive/v$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libopenblas.a

pack_set --command "make SANITY_CHECK=1 USE_OPENMP=1 NO_LAPACK=1 libs shared"
pack_set --command "make SANITY_CHECK=1 USE_OPENMP=1 NO_LAPACK=1 tests 2>&1 > tmp.test"
pack_set --command "make PREFIX=$(pack_get --install-prefix) install"
pack_set_mv_test tmp.test

done

