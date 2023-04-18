v=1.6.5
add_package --package pyquante \
    https://sourceforge.net/projects/pyquante/files/PyQuante-1.6/PyQuante-$v/PyQuante-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE
[ ${pV:2:5} -gt 10 ] && pack_set -host-reject $(get_hostname)

pack_set -module-requirement numpy

pack_set -install-query $(pack_get -prefix)/lib/python$pV/site-packages/

pack_cmd "mkdir -p $(pack_get -prefix)/lib/python$pV/site-packages/"

pack_cmd "unset LDFLAGS && $_pip_cmd . --prefix=$(pack_get -prefix)"
