sv=2.0
v=$sv.3
add_package http://www.open-mpi.org/software/hwloc/v$sv/downloads/hwloc-$v.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libhwloc.a

pack_set -build-mod-req build-tools
pack_set --module-requirement numactl --module-requirement libxml2

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
    pack_cmd "make check > hwloc.test 2>&1 ; echo force"
    pack_store hwloc.test
fi
pack_cmd "make install"
