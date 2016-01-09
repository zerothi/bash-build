v=1.0.2e
add_package --build generic --version $v --package openssl \
            ftp://ftp.openssl.org/source/openssl-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --mod-req gen-zlib

pack_set --install-query $(pack_get --prefix)/lib/libssl.a

# Install commands that it should run
pack_cmd "./config -fPIC --prefix=$(pack_get --prefix)" \
	"--openssldir=$(pack_get --prefix)/openssl"

# Make commands
pack_cmd "make"
pack_cmd "make install"
