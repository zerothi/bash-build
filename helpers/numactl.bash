v=2.0.12
add_package --build generic --archive numactl-$v.tar.gz \
    https://github.com/numactl/numactl/archive/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -build-mod-req build-tools
pack_set --install-query $(pack_get --prefix)/bin/numactl

pack_cmd "./autogen.sh"
pack_cmd "./configure --prefix=$(pack_get --prefix)"
pack_cmd "make"
pack_cmd "make install"
