add_package http://www.open-mpi.org/software/hwloc/v1.7/downloads/hwloc-1.7.2.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libhwloc.a

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --install-prefix)" \
	--command-flag "--disable-opencl" \
	--command-flag "--disable-cuda" \
	--command-flag "--disable-nvml" \
	--command-flag "--disable-gl" \
	--command-flag "--enable-static"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "check" \
    --command-flag "install"