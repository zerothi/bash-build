v=1.0
add_package --directory sympy-$v \
    --package sympy --version $v \
    https://github.com/sympy/sympy/releases/download/sympy-$v/sympy-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$(pack_get --alias)

pack_set $(list --prefix ' --module-requirement ' numpy cython scipy matplotlib)

pack_cmd "unset LDFLAGS && $(get_parent_exec) setup.py build ${pNumpyInstall%--fcom*}"

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

