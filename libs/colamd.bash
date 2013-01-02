add_package http://www.cise.ufl.edu/research/sparse/colamd/COLAMD-2.8.0.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --directory COLAMD
pack_set --install-query $(pack_get --install-prefix)/lib/libcolamd.a

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




# Add the COLAMD include directory to the path
add_package http://www.cise.ufl.edu/research/sparse/colamd/COLAMD-2.8.0.tar.gz
pack_set --directory COLAMD
pack_set --install-query /directory/does/not/exist
pack_set --alias COLAMD-make

# Edit the mk file to comply with the standards
mk=../SuiteSparse_config.mk
pack_set --command "sed -i -e 's|^[[:space:]]*CF[[:space:]]*=\(.*\)|CF = -I$(pack_get --install-prefix COLAMD)/include \1|' $mk"

