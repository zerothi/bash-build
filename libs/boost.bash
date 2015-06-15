add_package \
    --package boost \
    --version 1.58.0 \
    http://downloads.sourceforge.net/project/boost/boost/1.58.0/boost_1_58_0.tar.bz2

pack_set -s $IS_MODULE

pack_set --module-requirement mpi

pack_set --install-query $(pack_get --LD)/libboost_random.a

pack_set --command "./bootstrap.sh" \
    --command-flag "--with-libraries=all" \
    --command-flag "--without-libraries=python" \
    --command-flag "--prefix=$(pack_get --prefix)" \
    --command-flag "--includedir=$(pack_get --prefix)/include" \
    --command-flag "--libdir=$(pack_get --LD)"

# Install commands that it should run
pack_set --command "echo 'using mpi ;' >> project-config.jam"

# Make commands
pack_set --command "./b2 --build-dir=build-tmp --without-python stage"
pack_set --command "./b2 --build-dir=build-tmp --without-python install --prefix=$(pack_get --prefix)"

