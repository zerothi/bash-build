for v in 0.3.18 ; do
add_package -package openblas -archive OpenBLAS-$v.tar.gz \
	    https://github.com/xianyi/OpenBLAS/archive/v$v.tar.gz

pack_set -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libopenblas.a

pack_set -lib -lopenblas
pack_set -lib[omp] -lopenblas_omp
pack_set -lib[pt] -lopenblasp

# Default flags for all compilations of OpenBLAS here 
# Improve allocation for small matrices
# Allow up to 128 threads, regardless of scheme
def_flag="BINARY=64 SANITY_CHECK=1 MAX_STACK_ALLOC=2048 NUM_THREADS=256"
tmp_FFLAGS=${FFLAGS//-funroll-loops/}
tmp_CFLAGS=${CFLAGS//-funroll-loops/}
if $(is_c gnu-unsafe) ; then
    tmp_FFLAGS=${tmp_FFLAGS//-Ofast/-O3}
    tmp_CFLAGS=${tmp_CFLAGS//-Ofast/-O3}
elif $(is_c intel-unsafe) ; then
    tmp_FFLAGS=${tmp_FFLAGS//-Ofast/-O3}
    tmp_CFLAGS=${tmp_CFLAGS//-Ofast/-O3}
fi
def_flag="$def_flag LAPACK_FFLAGS='$tmp_FFLAGS' LAPACK_CFLAGS='$tmp_CFLAGS'"
def_flag="$def_flag FCFLAGS='$tmp_FFLAGS' CFLAGS='$tmp_CFLAGS'"
def_flag="$def_flag FCOMMON_OPT='$tmp_FCFLAGS' COMMON_OPT='$tmp_CFLAGS'"

# NO_LAPACK=1 means that we do not need -lgfortran
#pack_cmd "sed -i -s -e 's:-lgfortran::g' f_check"

_num_threads=256

for ver in thread none openmp ; do
    flag="$def_flag USE_THREAD=0"
    test_end=""
    case $ver in
	thread)
	    flag="$def_flag USE_THREAD=1 NUM_THREADS=$_num_threads"
	    test_end="_pt"
	    ;;
	openmp)
	    flag="$def_flag USE_OPENMP=1 USE_THREAD=1 NUM_THREADS=$_num_threads LIBNAMESUFFIX=omp"
	    test_end="_omp"
	    ;;
    esac

    # Ensure it is clean
    pack_cmd "make clean"
    pack_cmd "make $flag libs netlib shared"
    pack_cmd "make $flag tests 2>&1 > openblas.test || echo forced"
    pack_cmd "make $flag PREFIX=$(pack_get -prefix) install"
    pack_store openblas.test openblas.test.${test_end}
done

# Correct the linking of the threads library to make it easier to use
pack_cmd "pushd $(pack_get -prefix)/lib"
pack_cmd "ln -s libopenblas_[^o][^m][^^]*p-r*.a libopenblasp.a"
pack_cmd "ln -s libopenblas_[^o][^m][^^]*p-r*.so libopenblasp.so"
pack_cmd "popd"

unset def_flag flag test_end

add_hidden_package lapack-openblas/$v
pack_set -prefix $(pack_get -prefix openblas)
pack_set -installed $_I_REQ
pack_set -mod-req openblas
# Denote the default libraries
# Note that this OpenBLAS compilation has lapack built-in
pack_set -lib $(pack_get -lib openblas)
pack_set -lib[omp] $(pack_get -lib[omp] openblas)
pack_set -lib[pt] $(pack_get -lib[pt] openblas)
pack_set -lib[lapacke] ""


add_hidden_package scalapack-openblas/$v
pack_set -prefix $(pack_get -prefix openblas)
pack_set -installed $_I_REQ
pack_set $(list -prefix '-mod-req ' scalapack $(pack_get -mod-req lapack-openblas))
pack_set -lib $(pack_get -lib scalapack) $(pack_get -lib lapack-openblas)
pack_set -lib[omp] $(pack_get -lib scalapack) $(pack_get -lib[omp] lapack-openblas)
pack_set -lib[pt] $(pack_get -lib scalapack) $(pack_get -lib[pt] lapack-openblas)
pack_set -lib[lapacke] ""

done
