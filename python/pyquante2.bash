v=2.1
add_package --archive pyquante2-$v.tar.gz \
	    https://github.com/rpmuller/pyquante2/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE
[ "x${pV:0:1}" == "x3" ] && pack_set -host-reject $(get_hostname)

pack_set -module-requirement numpy

pack_set -install-query $(pack_get -prefix)/lib/python$pV/site-packages/

pack_cmd "mkdir -p $(pack_get -prefix)/lib/python$pV/site-packages/"

pack_cmd "unset LDFLAGS && $(get_parent_exec) setup.py build ${pNumpyInstallC}"
pack_cmd "$(get_parent_exec) setup.py install --prefix=$(pack_get -prefix)"
