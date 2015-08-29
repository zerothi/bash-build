v=2.1.2
add_package http://www.cise.ufl.edu/research/sparse/cholmod/CHOLMOD-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --directory CHOLMOD
pack_set --install-query $(pack_get --LD)/libcholmod.a

pack_set --module-requirement ss_config \
    --module-requirement amd \
    --module-requirement colamd \
    --module-requirement camd \
    --module-requirement ccolamd


pack_cmd "sed -i -e 's|^include ../SuiteSparse_config/\(.*\)|include ../\1|' *[Mm]akefile"
pack_cmd "sed -i -e 's|^include ../../SuiteSparse_config/\(.*\)|include ../../\1|' */*[Mm]akefile"

pack_cmd "sed -i -e 's|-I../SuiteSparse_config||g' *[Mm]akefile"
pack_cmd "sed -i -e 's|-I../../SuiteSparse_config||g' */*[Mm]akefile"

pack_cmd "sed -i -e 's|../SuiteSparse_config/SuiteSparse_config.h||g' *[Mm]akefile"
pack_cmd "sed -i -e 's|../../SuiteSparse_config/SuiteSparse_config.h||g' */*[Mm]akefile"

pack_cmd "sed -i -e 's|../AMD/Include/amd[^[:space:]]*.h|.|g' *[Mm]akefile"
pack_cmd "sed -i -e 's|../../AMD/Include/amd[^[:space:]]*.h|.|g' */*[Mm]akefile"

# Make commands
pack_cmd "make $(get_make_parallel) library"
# Install commands that it should run
pack_cmd "mkdir -p $(pack_get --LD)/"
pack_cmd "mkdir -p $(pack_get --prefix)/include/"
pack_cmd "make INSTALL_LIB='$(pack_get --LD)/'" \
	 "INSTALL_INCLUDE='$(pack_get --prefix)/include/'" \
	 "install"

pack_cmd "cp Include/cholmod_internal.h $(pack_get --prefix)/include"



# Add the CHOLMOD include directory to the path (we need to run this EVERY time)
add_package \
    --package CHOLMOD-make \
    http://www.cise.ufl.edu/research/sparse/cholmod/CHOLMOD-$v.tar.gz
pack_set --directory CHOLMOD
pack_set --install-query /directory/does/not/exist

# Edit the mk file to comply with the standards
mk=../SuiteSparse_config.mk
pack_cmd "sed -i -e 's|^[[:space:]]*CF[[:space:]]*=\(.*\)|CF = -I$(pack_get --prefix CHOLMOD)/include \1|' $mk"

