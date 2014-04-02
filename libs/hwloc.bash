# apt-get install libxml2
add_package http://www.open-mpi.org/software/hwloc/v1.9/downloads/hwloc-1.9.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libhwloc.a

# We don't need the libnuma (it only provides an interface to 
# use the libnuma routines for accessing hwloc)

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --install-prefix)" \
    --command-flag "--disable-libnuma" \
    --command-flag "--disable-opencl" \
    --command-flag "--disable-cuda" \
    --command-flag "--disable-nvml" \
    --command-flag "--disable-gl" \
    --command-flag "--enable-static"

# Make commands
pack_set --command "make $(get_make_parallel)"
#pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
#pack_set --command "mv tmp.test $(pack_get --install-prefix)/"

