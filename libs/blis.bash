v=0.1.8
add_package --archive blis-$v.tar.gz https://github.com/flame/blis/archive/$v.tar.gz

if ! $(is_c gnu) ; then
    pack_set --host-reject $(get_hostname)
fi

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
pack_cmd "make"
pack_cmd "make install"

pack_cmd "make clean cleanlib"

pack_cmd "sed -i -e 's?^\(BLIS_LIB_BASE_NAME\).*?\1 := libblis?' Makefile"
pack_cmd "sed -si -e 's?-fopenmp? ?g' config/*/*.mk"
pack_cmd "sed -si -e 's?-fopenmp? ?g' test/*/Makefile"
pack_cmd "make"
pack_cmd "make install"

add_hidden_package lapack-blis/$v
pack_set -mod-req blis
# Denote the default libraries
# Note that this OpenBLAS compilation has lapack built-in
pack_set --lib -llapack -lblis
pack_set --lib[omp] -llapack -lblis_omp
