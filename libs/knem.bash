# Requires kernel headers: linux-headers-$(uname -r)
add_package https://gitlab.inria.fr/knem/knem/uploads//4a43e3eb860cda2bbd5bf5c7c04a24b6/knem-1.1.4.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# What to check for when checking for installation...
pack_set -install-query $(pack_get -prefix)/bin/knem

pack_set -build-mod-req build-tools
pack_set -mod-req hwloc

# The default search is:
#  --with-linux-release=$(uname -r)
#  --with-linux=/lib/modules/$(uname -r)/source
#  --with-linux-build=/lib/modules/$(uname -r)/build
pack_cmd "../configure --prefix=$(pack_get -prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > knem.test 2>&1 || echo forced"
pack_store knem.test
pack_cmd "make install"
