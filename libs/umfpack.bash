v=5.6.2
add_package http://www.cise.ufl.edu/research/sparse/umfpack/UMFPACK-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --directory UMFPACK
pack_set --install-query $(pack_get --install-prefix)/lib/libumfpack.a

pack_set --module-requirement ss_config \
    --module-requirement amd \
    --module-requirement colamd \
    --module-requirement camd \
    --module-requirement ccolamd \
    --module-requirement cholmod

pack_set --command "sed -i -e 's|^include ../SuiteSparse_config/\(.*\)|include ../\1|' *[Mm]akefile"
pack_set --command "sed -i -e 's|^include ../../SuiteSparse_config/\(.*\)|include ../../\1|' */*[Mm]akefile"

pack_set --command "sed -i -e 's|-I../SuiteSparse_config||g' *[Mm]akefile"
pack_set --command "sed -i -e 's|-I../../SuiteSparse_config||g' */*[Mm]akefile"

pack_set --command "sed -i -e 's|../SuiteSparse_config/SuiteSparse_config.h||g' *[Mm]akefile"
pack_set --command "sed -i -e 's|../../SuiteSparse_config/SuiteSparse_config.h||g' */*[Mm]akefile"

pack_set --command "sed -i -e 's|../AMD/Include/amd[^[:space:]]*.h|.|g' *[Mm]akefile"
pack_set --command "sed -i -e 's|../../AMD/Include/amd[^[:space:]]*.h|.|g' */*[Mm]akefile"

pack_set --command "sed -i -e 's|^CONFIG[[:space:]]*=.*|CONFIG = |g' */*[Mm]akefile" # Only used for update checks

# Make commands
pack_set --command "make $(get_make_parallel) library"
# Install commands that it should run
pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/"
pack_set --command "mkdir -p $(pack_get --install-prefix)/include/"
pack_set --command "make INSTALL_LIB='$(pack_get --install-prefix)/lib/'" \
    --command-flag "INSTALL_INCLUDE='$(pack_get --install-prefix)/include/'" \
    --command-flag "install"




# Add the UMFPACK include directory to the path (we need to run this EVERY time)
add_package http://www.cise.ufl.edu/research/sparse/umfpack/UMFPACK-$v.tar.gz
pack_set --directory UMFPACK
pack_set --install-query /directory/does/not/exist
pack_set --alias UMFPACK-make

# Edit the mk file to comply with the standards
mk=../SuiteSparse_config.mk
pack_set --command "sed -i -e 's|^[[:space:]]*CF[[:space:]]*=\(.*\)|CF = -I$(pack_get --install-prefix UMFPACK)/include \1|' $mk"

