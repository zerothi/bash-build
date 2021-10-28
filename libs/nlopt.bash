return 0
add_package http://ab-initio.mit.edu/nlopt/nlopt-2.6.2.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libnlopt.a

######## Remark ########
# Needs to be installed after Python and numpy!
########################

pack_cmd "../configure" \
	 "PYTHON='$(pack_get --prefix python)/bin/python'" \
	 "--prefix $(pack_get --prefix)" \
	 "--enable-shared --with-cxx"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

