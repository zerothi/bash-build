v=2.1
add_package --archive pyquante2-$v.tar.gz \
	    https://github.com/rpmuller/pyquante2/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE
[ ${pV:2:5} -gt 10 ] && pack_set -host-reject $(get_hostname)

pack_set -module-requirement numpy

pack_set -install-query $(pack_get -prefix)/lib/python$pV/site-packages/

pack_cmd "mkdir -p $(pack_get -prefix)/lib/python$pV/site-packages/"

pack_cmd "unset LDFLAGS && $_pip_cmd . --prefix=$(pack_get -prefix)"
