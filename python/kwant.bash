[ "x${pV:0:1}" == "x3" ] && return 0

add_package http://downloads.kwant-project.org/kwant/kwant-1.0.3.tar.gz

pack_set -s $IS_MODULE

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

    for la in $(choice linalg) ; do
	if [[ $(pack_installed $la) -eq 1 ]]; then
	    pack_set --module-requirement $la
	    tmp=
	    case $la in
		atlas)
		    tmp="f77blas cblas"
		    ;;
		openblas)
		    la=openblas_omp
		    ;;
	    esac
	    tmp="$tmp $la"
	    break
	fi
    done

    pack_cmd "sed -i '1 a\
[lapack]\n\
libraries = lapack $tmp\n\
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
pack_cmd "nosetests -exe kwant  > tmp.test 2>&1 ; echo 'Success'"
pack_set_mv_test tmp.test
