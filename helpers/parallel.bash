add_package --build generic http://ftp.gnu.org/gnu/parallel/parallel-20160222.tar.bz2

pack_set -s $MAKE_PARALLEL

pack_set --prefix $(pack_get --prefix build-tools)

pack_set --install-query $(pack_get --prefix)/bin/parallel

# Install commands that it should run
pack_cmd "./configure --prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
