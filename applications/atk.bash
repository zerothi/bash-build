# Compiler not needed, so simply remove that variable
v=2014.2
add_package --build generic --package ATK --version $v \
    http://quantumwise.com/download/pkgs/VNL-ATK-$v-Linux64.bin

pack_set -s $IS_MODULE -s $CRT_DEF_MODULE

pack_set --install-query $(pack_get --prefix)/bin/atkpython

pack_set $(list -p '--host-reject ' zero ntch)

pack_set --module-opt "--lua-family ATK"

# Make the binary x
pack_set --command "chmod u+x $(build_get --archive-path)/$(pack_get --archive)"
pack_set --command "$(build_get --archive-path)/$(pack_get --archive)" \
    --command-flag "--prefix $(pack_get --prefix)" \
    --command-flag "--mode unattended --license_file non-existing" \
    --command-flag "--license_configuration floating"
