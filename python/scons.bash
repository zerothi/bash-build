[ "x${pV:0:1}" == "x3" ] && return 0

add_package http://prdownloads.sourceforge.net/scons/scons-2.3.2.tar.gz

pack_set -s $IS_MODULE

# Do not install here
pack_set --host-reject n- --host-reject hemera

pack_set --install-query $(pack_get --install-prefix)/bin/scons

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"
