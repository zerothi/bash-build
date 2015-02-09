for v in 0.2.13 ; do
add_package --package openblas --archive OpenBLAS-$v.tar.gz \
    https://github.com/xianyi/OpenBLAS/archive/v$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libopenblas.a

# NO_LAPACK=1 means that we do not need -lgfortran
pack_set --command "sed -i -s -e 's:-lgfortran::g' f_check"

# Default flags for all compilations of OpenBLAS here
def_flag="BINARY=64 SANITY_CHECK=1 NO_LAPACK=1"

for ver in thread none openmp ; do
    flag="$def_flag USE_THREAD=0"
    test_end=""
    if [ "$ver" == "thread" ]; then
	flag="$def_flag USE_THREAD=1"
	test_end="_pt"
    elif [ "$ver" == "openmp" ]; then
	flag="$def_flag USE_OPENMP=1 LIBNAMESUFFIX=omp"
	test_end="_omp"
    fi

    # Ensure it is clean
    pack_set --command "make clean"
    pack_set --command "make $flag libs shared"
    pack_set --command "make $flag tests 2>&1 > tmp.test"
    pack_set --command "make $flag PREFIX=$(pack_get --prefix) install"
    pack_set_mv_test tmp.test openblas${test_end}.test
done

# Correct the linking of the threads library to make it easier to use
pack_set --command "pushd $(pack_get --prefix)/lib"
pack_set --command "ln -s libopenblas_*p-r$(pack_get --version).a libopenblasp.a"
pack_set --command "ln -s libopenblas_*p-r$(pack_get --version).so libopenblasp.so"
pack_set --command "ln -s libopenblas_*p-r$(pack_get --version).so libopenblasp.so.0"
pack_set --command "popd"

unset def_flag flag test_end

done

