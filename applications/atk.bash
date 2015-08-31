# Compiler not needed, so simply remove that variable
v=2014.3
add_package --build generic --package ATK --version $v \
    http://quantumwise.com/download/pkgs/VNL-ATK-$v-Linux64.bin

pack_set -s $IS_MODULE -s $CRT_DEF_MODULE

pack_set --install-query $(pack_get --prefix)/bin/atkpython

pack_set --module-opt "--lua-family ATK"

# Make the binary x
pack_cmd "chmod u+x $(build_get --archive-path)/$(pack_get --archive)"
pack_cmd "$(build_get --archive-path)/$(pack_get --archive)" \
     "--prefix $(pack_get --prefix)" \
     "--mode unattended --license_file non-existing" \
     "--license_configuration floating"

# Define license servers etc.
if $(is_host n-) ; then
    # HPC, server @ QUANTUM_LICENSE_PATH=[6220]@license1.cc.dtu.dk
    pack_set --module-opt "--set-ENV QUANTUM_AUTOMATIC_SERVER_DISCOVERY=0"
    pack_set --module-opt "--set-ENV QUANTUM_LICENSE_PATH=\[6220\]\@license1.cc.dtu.dk"
fi

# Add license path to PATH
pack_set --module-opt "--prepend-ENV PATH=$(pack_get --prefix)/license"

