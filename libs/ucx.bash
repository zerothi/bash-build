v=1.5.1
add_package https://github.com/openucx/ucx/releases/download/v$v/ucx-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_TOOLS

# What to check for when checking for installation...
pack_set -install-query $(pack_get -prefix)/bin/ucx_info

pack_set -mod-req numactl

tmp_flags=
if [[ -d /usr/include/infiniband ]]; then
    tmp_flags="$tmp_flags --with-verbs"
fi

tmp_flags="$tmp_flags --with-rc --with-ud --with-dc --with-cm --with-mlx5-dv"
tmp_flags="$tmp_flags --with-ib-hw-tm --with-dm"
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
