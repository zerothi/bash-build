v=2.8.0
add_package http://www.cise.ufl.edu/research/sparse/ccolamd/CCOLAMD-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --directory CCOLAMD
pack_set --install-query $(pack_get --install-prefix)/lib/libccolamd.a

pack_set --module-requirement ss_config

pack_set --command "sed -i -e 's|^include ../SuiteSparse_config/\(.*\)|include ../\1|' *[Mm]akefile"
pack_set --command "sed -i -e 's|^include ../../SuiteSparse_config/\(.*\)|include ../../\1|' */*[Mm]akefile"

pack_set --command "sed -i -e 's|-I../SuiteSparse_config||g' *[Mm]akefile"
pack_set --command "sed -i -e 's|-I../../SuiteSparse_config||g' */*[Mm]akefile"

pack_set --command "sed -i -e 's|../SuiteSparse_config/SuiteSparse_config.h||g' *[Mm]akefile"
pack_set --command "sed -i -e 's|../../SuiteSparse_config/SuiteSparse_config.h||g' */*[Mm]akefile"


# Make commands
pack_set --command "make $(get_make_parallel) all"
# Install commands that it should run
pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/"
pack_set --command "mkdir -p $(pack_get --install-prefix)/include/"
pack_set --command "make INSTALL_LIB='$(pack_get --install-prefix)/lib/'" \
    --command-flag "INSTALL_INCLUDE='$(pack_get --install-prefix)/include/'" \
    --command-flag "install"




# Add the CCOLAMD include directory to the path
add_package \
    --package CCOLAMD-make \
    http://www.cise.ufl.edu/research/sparse/ccolamd/CCOLAMD-$v.tar.gz
pack_set --directory CCOLAMD
pack_set --install-query /directory/does/not/exist

# Edit the mk file to comply with the standards
mk=../SuiteSparse_config.mk
pack_set --command "sed -i -e 's|^[[:space:]]*CF[[:space:]]*=\(.*\)|CF = -I$(pack_get --install-prefix CCOLAMD)/include \1|' $mk"

