for v in 0.2.14.2 ; do
add_package --package openblas --archive OpenBLAS-$v.tar.gz --directory OpenBLAS-develop \
	    https://github.com/xianyi/OpenBLAS/archive/v$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libopenblas.a

# NO_LAPACK=1 means that we do not need -lgfortran
pack_cmd "sed -i -s -e 's:-lgfortran::g' f_check"

# Default flags for all compilations of OpenBLAS here 
# Improve allocation for small matrices
def_flag="BINARY=64 SANITY_CHECK=1 NO_LAPACK=1 MAX_STACK_ALLOC=2048"

for ver in thread none openmp ; do
    flag="$def_flag USE_THREAD=0"
    test_end=""
    case $ver in
	thread)
	    flag="$def_flag USE_THREAD=1"
	    test_end="_pt"
	    ;;
	openmp)
	    flag="$def_flag USE_OPENMP=1 USE_THREAD=1 LIBNAMESUFFIX=omp"
	    test_end="_omp"
	    ;;
    esac

    # Ensure it is clean
    pack_cmd "make clean"
    pack_cmd "make $flag libs shared"
    pack_cmd "make $flag tests 2>&1 > tmp.test"
    pack_cmd "make $flag PREFIX=$(pack_get --prefix) install"
    pack_set_mv_test tmp.test openblas${test_end}.test
done

# Correct the linking of the threads library to make it easier to use
pack_cmd "pushd $(pack_get --prefix)/lib"
pack_cmd "ln -s libopenblas_[^o]*p-r*.a libopenblasp.a"
pack_cmd "ln -s libopenblas_[^o]*p-r*.so libopenblasp.so"
pack_cmd "ln -s libopenblas_[^o]*p-r*.so libopenblasp.so.0"
pack_cmd "popd"

unset def_flag flag test_end

done

