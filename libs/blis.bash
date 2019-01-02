v=0.5.1
add_package --archive blis-$v.tar.gz https://github.com/flame/blis/archive/$v.tar.gz

if ! $(is_c gnu) ; then
    pack_set --host-reject $(get_hostname)
fi

pack_set --lib -lblis
pack_set --lib[omp] -lblis_omp
pack_set --lib[pt] -lblis_pt

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query $(pack_get --LD)/libblis.a

function blis_cpu {
    local flags="$1"
    shift
    declare -A check_hash
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
    local flags=$(grep flags /proc/cpuinfo | head -1)
    # Check for avx2
    if $(blis_cpu "$flags" avx2 intel_pt) ; then
	_ps haswell
	return
    fi
    if $(blis_cpu "$flags" avx2) ; then
	_ps zen
	return
    fi
    if $(blis_cpu "$flags" avx fma4 intel_pt) ; then
	_ps sandybridge
	return
    fi
    if $(blis_cpu "$flags" avx fma4) ; then
	_ps bulldozer
	return
    fi
    _ps generic
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

    pack_cmd "./configure -p $(pack_get --prefix) -t $model --enable-blas --enable-cblas $(blis_parse)"

    # Change library name
    pack_cmd "sed -i -e 's?^\(LIBBLIS_NAME\).*?\1 := libblis$name?' common.mk"
    
    pack_cmd "make $(get_make_parallel)"
    pack_cmd "make install"
    
    # Run test
    pack_cmd "cd testsuite"
    pack_cmd "make ; ./test_libblis.x > $model.test"
    pack_set_mv_test $model.test
    
    pack_cmd "cd .."

    pack_cmd "make clean cleanlib"

done
unset blis_cpu
unset blis_parse


# Add lapack-blis
add_hidden_package lapack-blis/$v
pack_set --prefix $(pack_get --prefix blis)
pack_set --installed $_I_REQ
pack_set -mod-req lapack
pack_set -mod-req blis
# Denote the default libraries
pack_set --lib -llapack $(pack_get -lib blis)
pack_set --lib[omp] -llapack $(pack_get -lib[omp] blis)
pack_set --lib[pt] -llapack $(pack_get -lib[pt] blis)
pack_set --lib[lapacke] -llapacke
				 
