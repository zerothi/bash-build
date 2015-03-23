# Compiler not needed, so simply remove that variable
v=2014.2
add_package --build generic --package ATK --version $v \
    http://quantumwise.com/download/pkgs/VNL-ATK-$v-Linux64.bin

pack_set --install-query $(pack_get --prefix)/bin/atkpython

pack_set $(list -p '--host-reject ' zero ntch)

pack_set --module-opt "--lua-family ATK"

# Make the binary x
pack_set --command "chmod u+x $(pack_get --archive)"
pack_set --command "$(pack_get --archive)" \
    --command-flag "--prefix $(pack_get --prefix)" \
    --command-flag "--mode unattended --license_file non-existing" \
    --command-flag "--license_configuration floating"

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version) \
    -P "/directory/should/not/exist" \
    -L $(pack_get --alias) 
