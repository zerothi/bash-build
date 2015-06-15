msg_install --message "Installing the SUITE SPARSE libraries..."

# A sparse library
source_pack libs/suitesparse_config.bash
source_pack libs/camd.bash
source_pack libs/amd.bash
source_pack libs/colamd.bash
source_pack libs/ccolamd.bash
source_pack libs/cholmod.bash
source_pack libs/umfpack.bash

