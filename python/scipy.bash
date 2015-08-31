for v in 0.15.1 ; do 
add_package http://downloads.sourceforge.net/project/scipy/scipy/$v/scipy-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$(pack_get --alias)

pack_set --module-requirement numpy
pack_set --module-requirement cython

if [[ $(pack_installed swig) -eq 1 ]]; then
    pack_cmd "module load $(pack_get --module-name-requirement pcre swig) $(pack_get --module-name pcre swig)"
fi

pack_cmd "unset LDFLAGS"

pack_cmd "CC=$CC $(get_parent_exec) setup.py build $pNumpyInstall"
pack_cmd "CC=$CC $(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

if [[ $(pack_installed swig) -eq 1 ]]; then
    pack_cmd "module unload $(pack_get --module-name swig pcre) $(pack_get --module-name-requirement pcre swig)"
fi


add_test_package
pack_cmd "unset LDFLAGS"
pack_cmd "nosetests --exe scipy > tmp.test 2>&1 ; echo 'Success'"
pack_set_mv_test tmp.test

done
