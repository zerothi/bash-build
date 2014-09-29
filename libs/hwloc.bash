add_package http://www.open-mpi.org/software/hwloc/v1.9/downloads/hwloc-1.9.1.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libhwloc.a

pack_set --module-requirement numactl --module-requirement libxml2

# Preload modules
pack_set --command "module load help2man m4 autoconf automake"

pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --prefix)" \
    --command-flag "--enable-libnuma" \
    --command-flag "--disable-opencl" \
    --command-flag "--disable-cuda" \
    --command-flag "--disable-nvml" \
    --command-flag "--disable-gl" \
    --command-flag "--enable-static"

# Make commands
pack_set --command "make $(get_make_parallel)"
if ! $(is_host n-) ; then
    pack_set --command "make check > tmp.test 2>&1"
    pack_set_mv_test tmp.test
fi
pack_set --command "make install"

pack_set --command "module unload automake autoconf m4 help2man"
