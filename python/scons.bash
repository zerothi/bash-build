v=4.0.0
add_package -archive scons-$v.tar.gz \
	    https://github.com/SCons/scons/archive/$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --prefix)/bin/scons

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"
