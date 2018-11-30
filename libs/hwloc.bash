sv=1.11
v=$sv.11
add_package http://www.open-mpi.org/software/hwloc/v$sv/downloads/hwloc-$v.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libhwloc.a

pack_set --module-requirement numactl --module-requirement libxml2

# Preload modules
pack_cmd "module load build-tools"

pack_cmd "./configure" \
	 "--prefix $(pack_get --prefix)" \
	 "--enable-libnuma" \
	 "--disable-opencl" \
	 "--disable-cuda" \
	 "--disable-nvml" \
	 "--disable-gl" \
	 "--enable-static"

# Make commands
pack_cmd "make $(get_make_parallel)"
if ! $(is_host n-) ; then
    pack_cmd "make check > tmp.test 2>&1 ; echo force"
    pack_set_mv_test tmp.test
fi
pack_cmd "make install"

pack_cmd "module unload build-tools"
