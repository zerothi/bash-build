# apt-get install libpng(12)-dev libfreetype6-dev

v=1.4.0
add_package \
    --archive matplotlib-$v.tar.gz \
    https://github.com/matplotlib/matplotlib/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py

pack_set --module-requirement numpy --module-requirement gen-freetype
if ! $(is_host hemera) ; then
	pack_set --module-requirement numpy --module-requirement gen-freetype
fi

pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py config"
pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build"
# Apparently matplotlib sucks at creating directories...
pack_set --command "mkdir -p $(pack_get --LD)/python$pV/site-packages/"
pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)"

add_test_package
pack_set --command "nosetests --exe matplotlib > tmp.test 2>&1 ; echo 'Succes'"
pack_set_mv_test tmp.test
