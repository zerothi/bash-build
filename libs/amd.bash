v=2.3.1
add_package http://www.cise.ufl.edu/research/sparse/amd/AMD-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --directory AMD
pack_set --install-query $(pack_get --LD)/libamd.a

pack_set --module-requirement ss_config

pack_cmd "sed -i -e 's|^include ../SuiteSparse_config/\(.*\)|include ../\1|' *[Mm]akefile"
pack_cmd "sed -i -e 's|^include ../../SuiteSparse_config/\(.*\)|include ../../\1|' */*[Mm]akefile"

pack_cmd "sed -i -e 's|-I../SuiteSparse_config||g' *[Mm]akefile"
pack_cmd "sed -i -e 's|-I../../SuiteSparse_config||g' */*[Mm]akefile"

pack_cmd "sed -i -e 's|../SuiteSparse_config/SuiteSparse_config.h||g' *[Mm]akefile"
pack_cmd "sed -i -e 's|../../SuiteSparse_config/SuiteSparse_config.h||g' */*[Mm]akefile"

pack_cmd "sed -i -e 's|^CONFIG[[:space:]]*=.*|CONFIG = |g' */*[Mm]akefile" # Only used for update checks


# Add a make-command for installing the Fortran lib
pack_cmd "echo 'install-fortran:' >> Makefile"
pack_cmd "echo -e '\t\$(CP) Lib/libamdf77.a \$(INSTALL_LIB)/libamdf77.\$(VERSION).a' >> Makefile"
pack_cmd "echo -e '\t( cd \$(INSTALL_LIB) ; ln -sf libamdf77.\$(VERSION).a libamdf77.a )' >> Makefile"

# Make commands
pack_cmd "make $(get_make_parallel) all"
pack_cmd "make $(get_make_parallel) fortran"
# Install commands that it should run
pack_cmd "mkdir -p $(pack_get --LD)/"
pack_cmd "mkdir -p $(pack_get --prefix)/include/"
pack_cmd "make INSTALL_LIB='$(pack_get --LD)/'" \
	 "INSTALL_INCLUDE='$(pack_get --prefix)/include/'" \
	 "install-fortran install"

pack_cmd "cp Include/amd_internal.h $(pack_get --prefix)/include"




# Add the AMD include directory to the path
add_package \
    --package AMD-make \
    http://www.cise.ufl.edu/research/sparse/amd/AMD-$v.tar.gz
pack_set --directory AMD
pack_set --install-query /directory/does/not/exist

# Edit the mk file to comply with the standards
mk=../SuiteSparse_config.mk
pack_cmd "sed -i -e 's|^[[:space:]]*CF[[:space:]]*=\(.*\)|CF = -I$(pack_get --prefix AMD)/include \1|' $mk"

