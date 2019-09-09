add_package --build generic http://tamacom.com/global/global-6.6.3.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/global

# Install commands that it should run
pack_cmd "./configure --prefix=$(pack_get --prefix) CFLAGS='$CFLAGS -std=gnu99'"

# Make commands
pack_cmd "make"
pack_cmd "make install"
