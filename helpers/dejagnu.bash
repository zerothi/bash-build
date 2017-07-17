# apt-get tcl-dev tk-dev expect
add_package --build generic http://mirrors.dotsrc.org/gnu/dejagnu/dejagnu-1.6.tar.gz

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR

pack_set --module-requirement build-tools
pack_set --prefix $(pack_get --prefix build-tools)

pack_set --install-query $(pack_get --prefix)/bin/runtest

# Install commands that it should run
pack_cmd "../configure" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
