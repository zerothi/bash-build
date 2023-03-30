v=1.11.1
add_package -directory sympy-$v \
    -package sympy -version $v \
    https://github.com/sympy/sympy/releases/download/sympy-$v/sympy-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE
# Not working on py2
[[ ${pV:0:1} -eq 2 ]] && pack_set -host-reject $(get_hostname)

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/sympy

pack_set $(list -prefix ' -module-requirement ' numpy cython scipy matplotlib)

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_cmd "unset LDFLAGS && $_pip_cmd . --prefix=$(pack_get -prefix)"

