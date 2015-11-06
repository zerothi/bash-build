add_package --build generic --version 1.0.2d --package openssl \
	    https://www.openssl.org/source/openssl-1.0.2d.tar.gz

pack_set -s $IS_MODULE

pack_set --mod-req gen-zlib

pack_set --install-query $(pack_get --prefix)/lib/libopenssl.so

# Install commands that it should run
pack_cmd "./config --prefix=$(pack_get --prefix)" \
	"--openssldir=$(pack_get --prefix)/openssl"

# Make commands
pack_cmd "make"
pack_cmd "make install"
