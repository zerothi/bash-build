add_package http://downloads.kwant-project.org/kwant/kwant-1.0.0.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/kwant/__init__.py

pack_set --module-opt "--lua-family kwant"

pack_set --module-requirement cython \
    --module-requirement numpy \
    --module-requirement mumps-serial \
    --module-requirement tinyarray

file=build.conf
pack_set --command "echo '#' > $file"

# Check for Intel MKL or not
tmp_flags="$(list --LDFLAGS --Wlrpath $(pack_get --module-requirement mumps-serial) mumps-serial)"
pack_set --command "sed -i '1 a\
extra_link_args = $tmp_flags \n\
' $file"
if $(is_c intel) ; then
    
    pack_set --command "sed -i '1 a\
[lapack]\n\
libraries = mkl_intel_lp64 mkl_sequential mkl_core mkl_def\n\
' $file"
    
elif $(is_c gnu) ; then
    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --module-requirement atlas
    else
	pack_set --module-requirement lapack
    fi

    pack_set --command "sed -i '1 a\
[lapack]\n\
libraries = f77blas cblas atlas atlas_lapack\n\
' $file"

else
    doerr kwant "Could not determine compiler..."
fi


pack_set --command "sed -i '1 a\
[mumps]\n\
libraries = zmumps mumps_common pord metis scotch\n\
' $file"

pack_set --command "CFLAGS='$CFLAGS $tmp_flags' $(get_parent_exec) setup.py build"

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"