v=1.11.1
add_package -directory sympy-$v \
    -package sympy -version $v \
    https://github.com/sympy/sympy/releases/download/sympy-$v/sympy-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/sympy

pack_set -build-mod-req cython
pack_set $(list -prefix ' -module-requirement ' numpy scipy matplotlib)

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_cmd "unset LDFLAGS && $_pip_cmd . --prefix=$(pack_get -prefix)"

