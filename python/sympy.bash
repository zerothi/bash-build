v=1.6.1
add_package -directory sympy-$v \
    -package sympy -version $v \
    https://github.com/sympy/sympy/releases/download/sympy-$v/sympy-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE
# Not working on py2
[[ ${pV:0:1} -eq 2 ]] && pack_set -host-reject $(get_hostname)

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/site.py

pack_set $(list -prefix ' -module-requirement ' numpy cython scipy matplotlib)

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_cmd "unset LDFLAGS && $(get_parent_exec) setup.py build $pNumpyInstallC"

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py install --prefix=$(pack_get -prefix)"

