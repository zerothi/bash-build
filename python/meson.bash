v=0.59.4
add_package https://github.com/mesonbuild/meson/releases/download/$v/meson-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --prefix)/bin/meson

[ "x${pV:0:1}" == "x2" ] && pack_set --host-reject $(get_hostname)

pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"
