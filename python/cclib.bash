v=1.6.1
add_package \
    https://github.com/cclib/cclib/releases/download/v$v/cclib-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -module-requirement biopython -mod-req pyquante

pack_set -install-query $(pack_get -prefix)/lib/python$pV/site-packages/

pack_cmd "mkdir -p $(pack_get -prefix)/lib/python$pV/site-packages/"

pack_cmd "unset LDFLAGS && $(get_parent_exec) setup.py build ${pNumpyInstallC}"
pack_cmd "$(get_parent_exec) setup.py install --prefix=$(pack_get -prefix)"
