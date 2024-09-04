v=5.4
add_package -directory ray -version $v -package radiance \
	    https://www.radiance-online.org/download-install/radiance-source-code/latest-release/rad${v:0:1}R${v:2:3}all.tar.gz

pack_set -s $IS_MODULE

pack_set -install-query $(pack_get -prefix)/bin/rad

pack_set -module-opt "-lua-family radiance"

pack_set -build-mod-req build-tools
pack_set -mod-req gen-libpng

pack_set -module-opt "-prepend-ENV RAYPATH=$(pack_get -prefix)/lib"

_prefix=$(pack_get -prefix)
pack_cmd "mkdir -p $_prefix/bin"
pack_cmd "mkdir -p $_prefix/lib"
pack_cmd "mkdir -p $_prefix/lib/meta"
pack_cmd "mkdir -p $_prefix/lib/lib"

# Clean using the shipped makefile
pack_cmd "./makeall clean"

# Fix shipped library build
pack_cmd "echo '$(pack_get -prefix)\ny\n2\nn' | EDITOR=vi ./makeall install CC='$CC' CXX='$CXX' OPT='$CFLAGS'"

