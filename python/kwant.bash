add_package http://downloads.kwant-project.org/kwant/kwant-1.3.3.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

if [[ $(vrs_cmp $pV 3.4) -lt 0 ]]; then
    pack_set --host-reject $(get_hostname)
fi

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py
pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"

pack_set --module-opt "--lua-family kwant"

pack_set --module-requirement cython \
    --module-requirement scipy \
    --module-requirement sympy \
    --module-requirement mumps-serial \
    --module-requirement tinyarray

file=build.conf
pack_cmd "echo '#' > $file"

# Check for Intel MKL or not
tmp_flags="$(list --LD-rp $(pack_get --mod-req mumps-serial) mumps-serial) $FLAG_OMP"
if $(is_c gnu) ; then
    tmp_flags="$tmp_flags -lgfortran"
fi
pack_cmd "sed -i '1 a\
extra_link_args = $tmp_flags \n' $file"
if $(is_c intel) ; then
    
    pack_cmd "sed -i '1 a\
[lapack]\n\
libraries = mkl_intel_lp64 mkl_sequential mkl_core mkl_def\n' $file"
    
elif $(is_c gnu) ; then

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp=$(pack_get -lib[omp] $la)
    case $la in
	lapack-openblas|lapack-acml)
	    tmp="${tmp//-l/}"
	    ;;
	*)
	    tmp="lapack ${tmp//-l/}"
	    ;;
    esac
    pack_cmd "sed -i '1 a\
[lapack]\n\
libraries = ${tmp//-l/}\n\
' $file"

else
    doerr kwant "Could not determine compiler..."
fi


pack_cmd "sed -i '1 a\
[mumps]\n\
libraries = zmumps_omp mumps_common_omp pord metis mpiseq\n\
' $file"

pack_cmd "CFLAGS='$pCFLAGS $tmp_flags' $(get_parent_exec) setup.py build"

pack_cmd "$(get_parent_exec) setup.py install" \
      "--prefix=$(pack_get --prefix)"


add_test_package kwant.test
pack_cmd "pytest --pyargs kwant 2>&1 > $TEST_OUT ; echo 'Success'"
pack_set_mv_test $TEST_OUT
