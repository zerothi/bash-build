[ "x${pV:0:1}" == "x3" ] && return 0

for v in 228 243 315 ; do
add_package \
    --package Inelastica-MATT \
    http://www.student.dtu.dk/~nicpa/packages/Inelastica-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --module-opt "--lua-family inelastica"

#pack_set --host-reject ntch --host-reject zero

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/Inelastica

pack_set --module-requirement netcdf-serial \
    --module-requirement scientificpython

# patch it...
if [ $(vrs_cmp $v 309) -lt 0 ]; then
    pack_set --command "wget http://www.student.dtu.dk/~nicpa/packages/Inelastica.py.patch-r$v"
    pack_set --command "wget http://www.student.dtu.dk/~nicpa/packages/inelastica.patch-r$v"
    pack_set --command "patch -R scripts/Inelastica inelastica.patch-r$v"
    pack_set --command "patch package/Inelastica.py Inelastica.py.patch-r$v"
    pack_set --command "wget http://www.student.dtu.dk/~nicpa/packages/NEGF_double_electrode_r$v"
    pack_set --command "patch package/NEGF.py NEGF_double_electrode_r$v"
else
    pack_set --command "wget http://www.student.dtu.dk/~nicpa/packages/NEGF_double_electrode_r$v"
    pack_set --command "patch -p0 < NEGF_double_electrode_r$v"
fi

pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build"

pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

done
