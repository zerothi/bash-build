v=0.2.1
add_package --archive blis-$v.tar.gz https://github.com/flame/blis/archive/$v.tar.gz

if ! $(is_c gnu) ; then
    pack_set --host-reject $(get_hostname)
fi

pack_set --lib -lblis
pack_set --lib[omp] -lblis_omp
pack_set --lib[pt] -lblis

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query $(pack_get --LD)/libblis.a

function blis_cpu {
    local flags="$1"
    shift
    local f=$1
    shift
    for f in $flags ; do
	case $tmp in
	    $f)
		return 0
		;;
	esac
    done
    return 1
}

# Get CPU info
function blis_parse {
    local flags=`grep flags /proc/cpuinfo | head -1`
    _ps reference
    return
    # Check for avx2
    if $(blis_cpu "$flags" avx2) ; then
	_ps haswell
	return
    fi
    if $(blis_cpu "$flags" avx) ; then
	if $(blis_cpu "$flags" fma) ; then
	    _ps bulldozer
	    return
	fi
	_ps sandybridge
	return
    fi
    _ps reference
}

pack_cmd "./configure -p $(pack_get --prefix) $(blis_parse)"
unset blis_cpu
unset blis_parse

# Create omp
pack_cmd "sed -i -e 's?^\(BLIS_LIB_BASE_NAME\).*?\1 := libblis_omp?' Makefile"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
# Run test
pack_cmd "cd testsuite"
pack_cmd "sed -i -e '/^BLIS_LIB/s?libblis.a?libblis_omp.a?' Makefile"
pack_cmd "make ; ./test_libblis.x > omp.test"
pack_set_mv_test omp.test
pack_cmd "make clean"
pack_cmd "sed -i -e '/^BLIS_LIB/s?libblis_omp.a?libblis.a?' Makefile"
pack_cmd "cd .."

pack_cmd "make clean cleanlib"

pack_cmd "sed -i -e 's?^\(BLIS_LIB_BASE_NAME\).*?\1 := libblis?' Makefile"
pack_cmd "sed -si -e 's?-fopenmp? ?g' config/*/*.mk"
pack_cmd "sed -si -e 's?-fopenmp? ?g' test/*/Makefile"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
# Run test
pack_cmd "cd testsuite"
pack_cmd "make ; ./test_libblis.x > single.test"
pack_set_mv_test single.test
pack_cmd "cd .."



# Add lapack-blis
add_hidden_package lapack-blis/$v
pack_set --installed $_I_REQ
pack_set -mod-req lapack
pack_set -mod-req blis
# Denote the default libraries
pack_set --lib -llapack $(pack_get -lib blis)
pack_set --lib[omp] -llapack $(pack_get -lib[omp] blis)
pack_set --lib[pt] -llapack $(pack_get -lib[pt] blis)
pack_set --lib[lapacke] -llapacke
				 
