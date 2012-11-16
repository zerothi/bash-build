add_package http://www.cise.ufl.edu/research/sparse/amd/AMD-2.3.1.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --directory AMD
pack_set --install-query $(pack_get --install-prefix)/lib/libamd.a

pack_set --module-requirement ss_config

pack_set --command "sed -i -e 's|^include ../SuiteSparse_config/\(.*\)|include ../\1|' *[Mm]akefile"
pack_set --command "sed -i -e 's|^include ../../SuiteSparse_config/\(.*\)|include ../../\1|' */*[Mm]akefile"

pack_set --command "sed -i -e 's|-I../SuiteSparse_config||g' *[Mm]akefile"
pack_set --command "sed -i -e 's|-I../../SuiteSparse_config||g' */*[Mm]akefile"

pack_set --command "sed -i -e 's|../SuiteSparse_config/SuiteSparse_config.h||g' *[Mm]akefile"
pack_set --command "sed -i -e 's|../../SuiteSparse_config/SuiteSparse_config.h||g' */*[Mm]akefile"

pack_set --command "sed -i -e 's|^CONFIG[[:space:]]*=.*|CONFIG = |g' */*[Mm]akefile" # Only used for update checks


# Add a make-command for installing the Fortran lib
pack_set --command "echo 'install-fortran:' >> Makefile"
pack_set --command "echo -e '\t\$(CP) Lib/libamdf77.a \$(INSTALL_LIB)/libamdf77.\$(VERSION).a' >> Makefile"
pack_set --command "echo -e '\t( cd \$(INSTALL_LIB) ; ln -sf libamdf77.\$(VERSION).a libamdf77.a )' >> Makefile"

# Make commands
pack_set --command "make $(get_make_parallel) all"
pack_set --command "make $(get_make_parallel) fortran"
# Install commands that it should run
pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/"
pack_set --command "mkdir -p $(pack_get --install-prefix)/include/"
pack_set --command "make INSTALL_LIB='$(pack_get --install-prefix)/lib/'" \
    --command-flag "INSTALL_INCLUDE='$(pack_get --install-prefix)/include/'" \
    --command-flag "install-fortran install"

pack_set --command "cp Include/amd_internal.h $(pack_get --install-prefix)/include"

pack_install



# Add the AMD include directory to the path
add_package http://www.cise.ufl.edu/research/sparse/amd/AMD-2.3.1.tar.gz
pack_set --directory AMD
pack_set --install-query /directory/does/not/exist
pack_set --alias AMD-make

# Edit the mk file to comply with the standards
mk=../SuiteSparse_config.mk
pack_set --command "sed -i -e 's|^[[:space:]]*CF[[:space:]]*=\(.*\)|CF = -I$(pack_get --install-prefix AMD)/include \1|' $mk"

pack_install