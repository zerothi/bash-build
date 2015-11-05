# Add the "fake" modules on HPC
if $(is_host n-) ; then
    add_hidden_package intel
    add_hidden_package intelmpi
    add_hidden_package intelmpifix
fi


# Compiler not needed, so simply remove that variable
v=2015.0
add_package --build generic --package ATK --version $v \
    http://quantumwise.com/download/pkgs/VNL-ATK-$v-Linux64.bin

pack_set -s $IS_MODULE -s $CRT_DEF_MODULE

pack_set --install-query $(pack_get --prefix)/bin/atkpython

pack_set --module-opt "--lua-family ATK"

# Make the binary x
pack_cmd "chmod u+x $(build_get --archive-path)/$(pack_get --archive)"

if [[ $(vrs_cmp $v 2015) -ge 0 ]]; then
    pack_cmd "$(build_get --archive-path)/$(pack_get --archive)" \
	"--prefix $(pack_get --prefix)" \
	"--unattendedmodeui none"
else
    pack_cmd "$(build_get --archive-path)/$(pack_get --archive)" \
	"--prefix $(pack_get --prefix)" \
	"--mode unattended --license_file non-existing" \
	"--license_configuration floating"
fi

atklic="201500982_DTU_A01693.lic"

# Define license servers etc.
if $(is_host n-) ; then
    # HPC, server @ QUANTUM_LICENSE_PATH=[6220]@license1.cc.dtu.dk
    pack_set --module-opt "--set-ENV QUANTUM_AUTOMATIC_SERVER_DISCOVERY=0"
    pack_set --module-opt "--set-ENV QUANTUM_LICENSE_PATH=\[6220\]\@license1.cc.dtu.dk:$(pack_get --prefix)/license/$atklic"

    # Add module loads
    pack_set --mod-req intel
    pack_set --mod-req intelmpi 
    pack_set --mod-req intelmpifix

fi

# Add license path to PATH
pack_set --module-opt "--prepend-ENV PATH=$(pack_get --prefix)/license"
# Copy license
pack_cmd "cp $(build_get --archive-path)/$atklic $(pack_get --prefix)/license/"
#pack_cmd "chmod a+r $(pack_get --prefix)/license/$atklic"

unset atklic
