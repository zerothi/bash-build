v=4.2.0
add_package -archive scons-$v.tar.gz \
	    https://github.com/SCons/scons/archive/$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

[[ ${pV:0:1} -eq 2 ]] && pack_set -host-reject $(get_hostname)

pack_set --install-query $(pack_get --prefix)/bin/scons

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py build install" \
    "--prefix=$(pack_get -prefix)"
