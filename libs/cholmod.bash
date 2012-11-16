add_package http://www.cise.ufl.edu/research/sparse/cholmod/CHOLMOD-2.0.1.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --directory CHOLMOD
pack_set --install-query $(pack_get --install-prefix)/lib/libcholmod.a

pack_set --module-requirement ss_config \
    --module-requirement amd \
    --module-requirement colamd \
    --module-requirement camd \
    --module-requirement ccolamd \


pack_set --command "sed -i -e 's|^include ../SuiteSparse_config/\(.*\)|include ../\1|' *[Mm]akefile"
pack_set --command "sed -i -e 's|^include ../../SuiteSparse_config/\(.*\)|include ../../\1|' */*[Mm]akefile"

pack_set --command "sed -i -e 's|-I../SuiteSparse_config||g' *[Mm]akefile"
pack_set --command "sed -i -e 's|-I../../SuiteSparse_config||g' */*[Mm]akefile"

pack_set --command "sed -i -e 's|../SuiteSparse_config/SuiteSparse_config.h||g' *[Mm]akefile"
pack_set --command "sed -i -e 's|../../SuiteSparse_config/SuiteSparse_config.h||g' */*[Mm]akefile"

pack_set --command "sed -i -e 's|../AMD/Include/amd[^[:space:]]*.h|.|g' *[Mm]akefile"
pack_set --command "sed -i -e 's|../../AMD/Include/amd[^[:space:]]*.h|.|g' */*[Mm]akefile"

# Make commands
pack_set --command "make $(get_make_parallel) library"
# Install commands that it should run
pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/"
pack_set --command "mkdir -p $(pack_get --install-prefix)/include/"
pack_set --command "make INSTALL_LIB='$(pack_get --install-prefix)/lib/'" \
    --command-flag "INSTALL_INCLUDE='$(pack_get --install-prefix)/include/'" \
    --command-flag "install"

pack_set --command "cp Include/cholmod_internal.h $(pack_get --install-prefix)/include"
pack_install



# Add the CHOLMOD include directory to the path (we need to run this EVERY time)
add_package http://www.cise.ufl.edu/research/sparse/cholmod/CHOLMOD-2.0.1.tar.gz
pack_set --directory CHOLMOD
pack_set --install-query /directory/does/not/exist
pack_set --alias CHOLMOD-make

# Edit the mk file to comply with the standards
mk=../SuiteSparse_config.mk
pack_set --command "sed -i -e 's|^[[:space:]]*CF[[:space:]]*=\(.*\)|CF = -I$(pack_get --install-prefix CHOLMOD)/include \1|' $mk"

pack_install