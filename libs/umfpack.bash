v=5.6.2
add_package http://www.cise.ufl.edu/research/sparse/umfpack/UMFPACK-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --directory UMFPACK
pack_set --install-query $(pack_get --LD)/libumfpack.a

pack_set --module-requirement ss_config \
    --module-requirement amd \
    --module-requirement colamd \
    --module-requirement camd \
    --module-requirement ccolamd \
    --module-requirement cholmod

pack_cmd "sed -i -e 's|^include ../SuiteSparse_config/\(.*\)|include ../\1|' *[Mm]akefile"
pack_cmd "sed -i -e 's|^include ../../SuiteSparse_config/\(.*\)|include ../../\1|' */*[Mm]akefile"

pack_cmd "sed -i -e 's|-I../SuiteSparse_config||g' *[Mm]akefile"
pack_cmd "sed -i -e 's|-I../../SuiteSparse_config||g' */*[Mm]akefile"

pack_cmd "sed -i -e 's|../SuiteSparse_config/SuiteSparse_config.h||g' *[Mm]akefile"
pack_cmd "sed -i -e 's|../../SuiteSparse_config/SuiteSparse_config.h||g' */*[Mm]akefile"

pack_cmd "sed -i -e 's|../AMD/Include/amd[^[:space:]]*.h|.|g' *[Mm]akefile"
pack_cmd "sed -i -e 's|../../AMD/Include/amd[^[:space:]]*.h|.|g' */*[Mm]akefile"

pack_cmd "sed -i -e 's|^CONFIG[[:space:]]*=.*|CONFIG = |g' */*[Mm]akefile" # Only used for update checks

# Make commands
pack_cmd "make $(get_make_parallel) library"
# Install commands that it should run
pack_cmd "mkdir -p $(pack_get --LD)/"
pack_cmd "mkdir -p $(pack_get --prefix)/include/"
pack_cmd "make INSTALL_LIB='$(pack_get --LD)/'" \
	 "INSTALL_INCLUDE='$(pack_get --prefix)/include/'" \
	 "install"


# Add the UMFPACK include directory to the path (we need to run this EVERY time)
add_package \
    --package UMFPACK-make \
    http://www.cise.ufl.edu/research/sparse/umfpack/UMFPACK-$v.tar.gz
pack_set --directory UMFPACK
pack_set --install-query /directory/does/not/exist

# Edit the mk file to comply with the standards
mk=../SuiteSparse_config.mk
pack_cmd "sed -i -e 's|^[[:space:]]*CF[[:space:]]*=\(.*\)|CF = -I$(pack_get --prefix UMFPACK)/include \1|' $mk"

