v=0.7.0
add_package -archive blis-$v.tar.gz https://github.com/flame/blis/archive/$v.tar.gz

if ! $(is_c gnu) ; then
    pack_set -host-reject $(get_hostname)
fi

pack_set -lib -lblis
pack_set -lib[omp] -lblis_omp
pack_set -lib[pt] -lblis_pt

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -prefix-and-module $(pack_get -alias)/$(pack_get -version)

pack_set -install-query $(pack_get -LD)/libblis.a

function blis_cpu {
    local flags="$1"
    shift
    local -A check_hash
    for f in $flags ; do
	check_hash[$f]='x'
    done
    while [[ $# -gt 0 ]]; do
	[[ "x${check_hash[$1]}" == "x" ]] && return 1
	shift
    done
    return 0
}

# Get CPU info
function blis_parse {
    printf '%s' 'auto'
    return
    local flags=$(grep flags /proc/cpuinfo | head -1)
    # Check for avx2
    if $(blis_cpu "$flags" avx2 intel_pt) ; then
	printf '%s' 'haswell'
	return
    fi
    if $(blis_cpu "$flags" avx2) ; then
	printf '%s' 'zen'
	return
    fi
    if $(blis_cpu "$flags" avx fma4 intel_pt) ; then
	printf '%s' 'sandybridge'
	return
    fi
    if $(blis_cpu "$flags" avx fma4) ; then
	printf '%s' 'bulldozer'
	return
    fi
    printf '%s' 'auto'
}

for model in no openmp pthreads
do
    case $model in
	no)
	    name=""
	    ;;
	openmp)
	    name="_omp"
	    ;;
	pthreads)
	    name="_pt"
	    ;;
    esac

    pack_cmd "./configure -p $(pack_get -prefix) -t $model --enable-blas --enable-cblas $(blis_parse)"
    
    # versions prior to 0.5.0 used LIBBLIS_NAME
    pack_cmd "make LIBBLIS=libblis$name $(get_make_parallel)"
    pack_cmd "make LIBBLIS=libblis$name install"
    pack_cmd "make LIBBLIS=libblis$name check 2>&1 > $model.test"

    # Run test
    pack_cmd "cd testsuite"
    pack_cmd "make LIBBLIS=libblis$name ; ./test_libblis.x >> ../$model.test"
    pack_cmd "cd .."
    pack_store $model.test

    pack_cmd "make clean cleanlib"

done
unset blis_cpu
unset blis_parse


# Add lapack-blis
add_hidden_package lapack-blis/$v
pack_set -prefix $(pack_get -prefix blis)
pack_set -installed $_I_REQ
pack_set -mod-req lapack
pack_set -mod-req blis
# Denote the default libraries
pack_set -lib -llapack $(pack_get -lib blis)
pack_set -lib[omp] -llapack $(pack_get -lib[omp] blis)
pack_set -lib[pt] -llapack $(pack_get -lib[pt] blis)
pack_set -lib[lapacke] -llapacke


add_hidden_package scalapack-blis/$v
pack_set -prefix $(pack_get -prefix blis)
pack_set -installed $_I_REQ
pack_set $(list -prefix '-mod-req ' scalapack $(pack_get -mod-req lapack-blis[$v]))
pack_set -lib $(pack_get -lib scalapack) $(pack_get -lib lapack-blis[$v])
pack_set -lib[omp] $(pack_get -lib scalapack) $(pack_get -lib[omp] lapack-blis[$v])
pack_set -lib[pt] $(pack_get -lib scalapack) $(pack_get -lib[pt] lapack-blis[$v])
pack_set -lib[lapacke] -llapacke
