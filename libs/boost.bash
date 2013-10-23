add_package \
    --package boost \
    --version 1.54.0 \
    http://downloads.sourceforge.net/project/boost/boost/1.54.0/boost_1_54_0.tar.bz2

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

