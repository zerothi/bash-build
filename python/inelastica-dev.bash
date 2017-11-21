[ "x${pV:0:1}" == "x3" ] && return 0

for v in 228 441 ; do
add_package \
    --package Inelastica-DEV \
    http://www.student.dtu.dk/~nicpa/packages/Inelastica-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --module-opt "--lua-family inelastica"

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/Inelastica

pack_set --module-requirement netcdf-serial
if [[ $v -gt 349 ]]; then
    pack_set --module-requirement scipy
fi
if [[ $v -gt 425 ]]; then
    pack_set --module-requirement netcdf4py
else
    pack_set --module-requirement scientificpython
fi

if [[ $(pack_get --version) -lt 260 ]]; then
    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-Inelastica.py.patch-p$v
    dwn_file http://www.student.dtu.dk/~nicpa/packages/Inelastica.py.patch-r$v $o
    pack_cmd "patch package/Inelastica.py $o"
    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-inelastica.patch-p$v
    dwn_file http://www.student.dtu.dk/~nicpa/packages/inelastica.patch-r$v $o
    pack_cmd "patch -R scripts/Inelastica $o"
fi

pack_cmd "unset LDFLAGS && $(get_parent_exec) setup.py config"
pack_cmd "unset LDFLAGS && $(get_parent_exec) setup.py build"

pack_cmd "unset LDFLAGS && $(get_parent_exec) setup.py install" \
      "--prefix=$(pack_get --prefix)"

done
