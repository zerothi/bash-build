add_package -build debug http://www.open-mpi.org/software/otpo/v1.0/downloads/otpo-1.0.tar.bz2

pack_set -s $IS_MODULE

pack_set -build-mod-req build-tools

if [[ $_mpi_version != "openmpi" ]]; then
    pack_set -host-reject $(get_hostname)
fi

# What to check for when checking for installation...
pack_set -install-query $(pack_get -prefix)/bin/otpo

pack_cmd "./autogen.sh"

# Install commands that it should run
pack_cmd "./configure --prefix=$(pack_get -prefix)"

# Sadly, it does not get the command line for LIBS
# Hence we need to automatically prepend it to the linker line
pack_cmd "sed -i -e 's/^LIBS[[:space:]]*=\(.*\)/LIBS = \1 -lstdc++/' Makefile"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
pack_cmd "cp OpenIB_Parameters $(pack_get -prefix)/"
