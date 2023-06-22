add_package http://downloads.kwant-project.org/kwant/kwant-1.4.3.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

if [[ $(vrs_cmp $pV 3.5) -lt 0 ]]; then
    pack_set -host-reject $(get_hostname)
fi

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/kwant
pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_set -module-opt "-lua-family kwant"

pack_set -build-mod-req cython
pack_set -module-requirement scipy \
    -module-requirement sympy \
    -module-requirement mumps-serial \
    -module-requirement tinyarray

file=build.conf
pack_cmd "echo '#' > $file"

# Check for Intel MKL or not
tmp_flags="$(list -LD-rp ++mumps-serial) $FLAG_OMP"
if $(is_c gnu) ; then
    tmp_flags="$tmp_flags -lgfortran"
fi

# LAPACK libraries (MUMPS requires it)
tmp=
if $(is_c intel) ; then

    tmp="mkl_intel_lp64 mkl_sequential mkl_core mkl_def"
    pack_cmd "sed -i '1 a\
[kwant.linalg.lapack]\n\
libraries = $tmp\n\
extra_link_args = $tmp_flags\n\
' $file"
    
elif $(is_c gnu) ; then

    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    tmp=$(pack_get -lib[omp] $la)
    case $la in
	lapack-openblas|lapack-acml) # packages with LAPACK build-in
	    tmp="${tmp//-l/}"
	    ;;
	*)
	    tmp="lapack ${tmp//-l/}"
	    ;;
    esac
    pack_cmd "sed -i '1 a\
[kwant.linalg.lapack]\n\
libraries = $tmp\n\
extra_link_args = $tmp_flags\n\
' $file"

else
    doerr kwant "Could not determine compiler..."
fi


pack_cmd "sed -i '1 a\
[kwant.linalg._mumps]\n\
libraries = zmumps_omp mumps_common_omp pord metis mpiseq $tmp\n\
include_dirs = $(pack_get -prefix mumps-serial)/include\n\
extra_link_args = $tmp_flags\n\
' $file"

pack_cmd "CFLAGS='$pCFLAGS $tmp_flags' $_pip_cmd . --config-settings='--build-options=--cython' --config-settings='--configfile=$file' --prefix=$(pack_get -prefix)"


add_test_package kwant.test
pack_cmd "pytest --pyargs kwant 2>&1 > $TEST_OUT || echo forced"
pack_store $TEST_OUT
