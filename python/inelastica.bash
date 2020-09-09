
# Since v1.3.5 Inelastica supports Py3
#[ "x${pV:0:1}" == "x3" ] && return 0

v=1.3.7
add_package -package Inelastica \
	    -archive inelastica-$v.tar.gz \
	    https://github.com/tfrederiksen/inelastica/archive/v$v.tar.gz

pack_set -s $IS_MODULE

pack_set -module-opt "-lua-family inelastica"

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/Inelastica

pack_set -module-requirement scipy \
	 -module-requirement netcdf4py


pack_cmd "unset LDFLAGS && $(get_parent_exec) setup.py build ${pNumpyInstall}"
pack_cmd "unset LDFLAGS && $(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get -prefix)"


