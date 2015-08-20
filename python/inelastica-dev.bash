[ "x${pV:0:1}" == "x3" ] && return 0

for v in 228 279 286 303 323 350 ; do
add_package \
    --package Inelastica-DEV \
    http://www.student.dtu.dk/~nicpa/packages/Inelastica-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --module-opt "--lua-family inelastica"

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/Inelastica

pack_set --module-requirement netcdf-serial \
    --module-requirement scientificpython

if [ $(pack_get --version) -lt 260 ]; then
    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-Inelastica.py.patch-p$v
    dwn_file http://www.student.dtu.dk/~nicpa/packages/Inelastica.py.patch-r$v $o
    pack_set --command "patch package/Inelastica.py $o"
    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-inelastica.patch-p$v
    dwn_file http://www.student.dtu.dk/~nicpa/packages/inelastica.patch-r$v $o
    pack_set --command "patch -R scripts/Inelastica $o"
fi

pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py config"
pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build"

pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)"

done
