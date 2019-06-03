add_package http://prdownloads.sourceforge.net/scons/scons-2.3.2.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/scons

[ "x${pV:0:1}" == "x3" ] && pack_set --host-reject $(get_hostname)

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"
