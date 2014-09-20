[ "x${pV:0:1}" == "x3" ] && return 0

for v in 228 243 315 ; do
add_package \
    --package Inelastica-MATT \
    http://www.student.dtu.dk/~nicpa/packages/Inelastica-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --module-opt "--lua-family inelastica"

#pack_set --host-reject ntch --host-reject zero

pack_set --install-query $(pack_get --library-path)/python$pV/site-packages/Inelastica

pack_set --module-requirement netcdf-serial \
    --module-requirement scientificpython

# patch it...
if [ $(vrs_cmp $v 309) -lt 0 ]; then
    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-Inelastica.py.patch-p$v
    mywget http://www.student.dtu.dk/~nicpa/packages/Inelastica.py.patch-r$v $o
    pack_set --command "patch package/Inelastica.py $o"
    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-inelastica.patch-p$v
    mywget http://www.student.dtu.dk/~nicpa/packages/inelastica.patch-r$v $o
    pack_set --command "patch -R scripts/Inelastica $o"
    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-NEGF_double_electrode_r$v
    mywget http://www.student.dtu.dk/~nicpa/packages/NEGF_double_electrode_r$v $o
    pack_set --command "patch package/NEGF.py $o"
else
    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-NEGF_double_electrode_r$v
    mywget http://www.student.dtu.dk/~nicpa/packages/NEGF_double_electrode_r$v $o
    pack_set --command "patch -p0 < $o"
fi

pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build"

pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

done
