return 0
add_package --package npb \
    https://www.nas.nasa.gov/assets/npb/NPB3.4.3.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR
pack_set -install-query $(pack_get -prefix)/bin/lu.x

pack_set -module-requirement mpi
pack_set -module-opt "-set-ENV NPB_HOME=$(pack_get -prefix)"

# not done



