for v in 0.17.0 ; do 
add_package https://github.com/scipy/scipy/releases/download/v$v/scipy-$v.tar.xz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$(pack_get --alias)

pack_set --module-requirement numpy
pack_set --module-requirement cython

# The later LAPACK versions have gegv routines deprecated and replaced by ggev
# However, ggev routines are already existing.
if [[ $(vrs_cmp $v 0.16.0) -ge 0 ]]; then
if $(is_c gnu) ; then
    pack_cmd "pushd scipy/linalg"
    pack_cmd "sed -i '/[sdcz]gegs/d' cython_lapack_signatures.txt"
    pack_cmd "sed -i '/[sdcz]gegv/d' cython_lapack_signatures.txt"
    pack_cmd "sed -i '/[sdcz]gelsx/d' cython_lapack_signatures.txt"
    pack_cmd "sed -i '/[sdcz]geqpf/d' cython_lapack_signatures.txt"
    pack_cmd "sed -i '/[sdcz]ggsvd/d' cython_lapack_signatures.txt"
    pack_cmd "sed -i '/[sdcz]ggsvp/d' cython_lapack_signatures.txt"
    pack_cmd "sed -i '/[sdcz]lahrd/d' cython_lapack_signatures.txt"
    pack_cmd "sed -i '/[sdcz]latzm/d' cython_lapack_signatures.txt"
    pack_cmd "sed -i '/[sdcz]tzrqf/d' cython_lapack_signatures.txt"
    pack_cmd "$(get_parent_exec) _cython_wrapper_generators.py"
    # Remove interfaces in flapack.pyf.src
    pack_cmd "sed -i '/2[c]*>gegv/{N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;d}' flapack.pyf.src"
    pack_cmd "popd"
    pack_cmd "$(get_parent_exec) tools/cythonize.py"
fi
fi

if [[ $(pack_installed swig) -eq 1 ]]; then
    pack_cmd "module load $(list ++swig)"
fi

pack_cmd "unset LDFLAGS"

pack_cmd "$(get_parent_exec) setup.py build $pNumpyInstall"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

if [[ $(pack_installed swig) -eq 1 ]]; then
    pack_cmd "module unload $(list ++swig)"
fi


add_test_package
pack_cmd "unset LDFLAGS"
pack_cmd "nosetests --exe scipy > tmp.test 2>&1 ; echo 'Success'"
pack_set_mv_test tmp.test

done
