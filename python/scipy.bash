for v in 0.15.1 ; do 
add_package http://downloads.sourceforge.net/project/scipy/scipy/$v/scipy-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$(pack_get --alias)

pack_set --module-requirement numpy
pack_set --module-requirement cython

if [ $(pack_installed swig) -eq 1 ]; then
    pack_set --command "module load $(pack_get --module-name-requirement pcre swig) $(pack_get --module-name pcre swig)"
fi

pack_set --command "unset LDFLAGS"

pack_set --command "CC=$CC $(get_parent_exec) setup.py build $pNumpyInstall"
pack_set --command "CC=$CC $(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)"

if [ $(pack_installed swig) -eq 1 ]; then
    pack_set --command "module unload $(pack_get --module-name swig pcre) $(pack_get --module-name-requirement pcre swig)"
fi


add_test_package
pack_set --command "unset LDFLAGS"
pack_set --command "nosetests --exe scipy > tmp.test 2>&1 ; echo 'Succes'"
pack_set_mv_test tmp.test

done
