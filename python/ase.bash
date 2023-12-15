for v in 3.19.1 3.20.1 3.22.1 ; do

add_package https://gitlab.com/ase/ase/-/archive/$v/ase-$v.tar.bz2

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -module-opt "-lua-family ase"
# Not working on py2
[[ ${pV:0:1} -eq 2 ]] && pack_set -host-reject $(get_hostname)

pack_set -install-query $(pack_get -prefix)/bin/ase

pack_set -module-requirement scipy
pack_set -module-requirement matplotlib

pack_cmd "mkdir -p $(pack_get -prefix)/lib/python$pV/site-packages"
pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"

done
