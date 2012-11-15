return 0
add_package http://ab-initio.mit.edu/nlopt/nlopt-2.3.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libnlopt.a

######## Remark ########
# Needs to be installed after Python and numpy!
########################


pack_set --command "../configure" \
    --command-flag "PYTHON='$(pack_get --install-prefix python)/bin/python'" \
    --command-flag "--prefix $(pack_get --install-prefix)" \
    --command-flag "--enable-shared --with-cxx"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

pack_install
