[ "x${pV:0:1}" == "x3" ] && return 0

add_package http://downloads.kwant-project.org/kwant/kwant-1.1.1.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/kwant/__init__.py

pack_set --module-opt "--lua-family kwant"

pack_set --module-requirement cython \
    --module-requirement scipy \
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
libraries = zmumps_omp mumps_common_omp pord metis\n\
' $file"

pack_cmd "CFLAGS='$pCFLAGS $tmp_flags' $(get_parent_exec) setup.py build"

pack_cmd "$(get_parent_exec) setup.py install" \
      "--prefix=$(pack_get --prefix)"


add_test_package
pack_cmd "nosetests -exe kwant 2>&1 > tmp.test ; echo 'Success'"
pack_set_mv_test tmp.test
