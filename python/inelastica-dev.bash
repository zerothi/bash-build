[ "x${pV:0:1}" == "x3" ] && return 0

for v in 228 279 286 303 315 ; do
add_package \
    --package Inelastica-DEV \
    http://www.student.dtu.dk/~nicpa/packages/Inelastica-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --module-opt "--lua-family inelastica"

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/Inelastica

pack_set --module-requirement netcdf-serial \
    --module-requirement scientificpython

if [ $(pack_get --version) -lt 260 ]; then
# patch it...
pack_set --command "wget http://www.student.dtu.dk/~nicpa/packages/Inelastica.py.patch-r$v"
pack_set --command "wget http://www.student.dtu.dk/~nicpa/packages/inelastica.patch-r$v"
pack_set --command "patch -R scripts/Inelastica inelastica.patch-r$v"
pack_set --command "patch package/Inelastica.py Inelastica.py.patch-r$v"
fi

pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py config"
pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build"

pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

done
