v=2.0.10
add_package --build generic --archive numactl-$v.tar.gz \
    https://github.com/numactl/numactl/archive/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/numactl

# Set the suffix
pack_set --library-suffix lib64

# Make commands
# Load autoconf
pack_cmd "module load $(list +autoconf)"

pack_cmd "./autogen.sh"
pack_cmd "./configure --prefix=$(pack_get --prefix)"
pack_cmd "make"
pack_cmd "make install"
