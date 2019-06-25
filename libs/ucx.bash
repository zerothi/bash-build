v=1.6.0-rc3
add_package https://github.com/openucx/ucx/releases/download/v$v/ucx-${v//-rc*/}.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# What to check for when checking for installation...
pack_set -install-query $(pack_get -prefix)/bin/ucx_info

pack_set -build-mod-req build-tools
pack_set -mod-req numactl

tmp_flags=
if [[ -d /usr/include/infiniband ]]; then
    tmp_flags="$tmp_flags --with-verbs"
fi

if ! $(is_host nicpa) ; then
    tmp_flags="$tmp_flags --with-cm"
    tmp_flags="$tmp_flags --with-mlx5-dv"
    tmp_flags="$tmp_flags --with-ib-hw-tm"
fi

tmp_flags="$tmp_flags --with-rc --with-ud --with-dc"
tmp_flags="$tmp_flags --with-dm"
tmp_flags="$tmp_flags --with-mcpu --with-march"

# Install commands that it should run
pack_cmd "unset MPICC ; unset MPICXX ; unset MPIFC"
pack_cmd "../contrib/configure-release  $tmp_flags" \
	 "--prefix=$(pack_get -prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > ucx.test 2>&1 ; echo 'force'"
pack_store ucx.test
pack_cmd "make install"
