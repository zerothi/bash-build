v=2.8.0
add_package http://www.cise.ufl.edu/research/sparse/colamd/COLAMD-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --directory COLAMD
pack_set --install-query $(pack_get --LD)/libcolamd.a

pack_set --module-requirement ss_config

pack_cmd "sed -i -e 's|^include ../SuiteSparse_config/\(.*\)|include ../\1|' *[Mm]akefile"
pack_cmd "sed -i -e 's|^include ../../SuiteSparse_config/\(.*\)|include ../../\1|' */*[Mm]akefile"

pack_cmd "sed -i -e 's|-I../SuiteSparse_config||g' *[Mm]akefile"
pack_cmd "sed -i -e 's|-I../../SuiteSparse_config||g' */*[Mm]akefile"

pack_cmd "sed -i -e 's|../SuiteSparse_config/SuiteSparse_config.h||g' *[Mm]akefile"
pack_cmd "sed -i -e 's|../../SuiteSparse_config/SuiteSparse_config.h||g' */*[Mm]akefile"


# Make commands
pack_cmd "make $(get_make_parallel) all"
# Install commands that it should run
pack_cmd "mkdir -p $(pack_get --LD)/"
pack_cmd "mkdir -p $(pack_get --prefix)/include/"
pack_cmd "make INSTALL_LIB='$(pack_get --LD)/'" \
	 "INSTALL_INCLUDE='$(pack_get --prefix)/include/'" \
	 "install"




# Add the COLAMD include directory to the path
add_package \
    --package COLAMD-make \
    http://www.cise.ufl.edu/research/sparse/colamd/COLAMD-$v.tar.gz
pack_set --directory COLAMD
pack_set --install-query /directory/does/not/exist

# Edit the mk file to comply with the standards
mk=../SuiteSparse_config.mk
pack_cmd "sed -i -e 's|^[[:space:]]*CF[[:space:]]*=\(.*\)|CF = -I$(pack_get --prefix COLAMD)/include \1|' $mk"

