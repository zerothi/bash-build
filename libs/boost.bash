# First install zlib, which is a simple library
add_package http://downloads.sourceforge.net/project/boost/boost/1.52.0/boost_1_52_0.tar.bz2

pack_set --version 1.52.0

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libboost_python.a

# Install commands that it should run
pack_set --command "echo \"using mpi;\" >> tools/build/v2/user-config.jam"
pack_set --command "./bootstrap.sh" \
    --command-flag "--with-libraries=all" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--includedir=$(pack_get --install-prefix)/include" \
    --command-flag "--libdir=$(pack_get --install-prefix)/lib"

# Make commands
pack_set --command "./b2 stage"
pack_set --command "./b2 install"

