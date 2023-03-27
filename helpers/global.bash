add_package --build generic https://ftp.gnu.org/pub/gnu/global/global-6.6.9.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/global

# Install commands that it should run
pack_cmd "./configure --prefix=$(pack_get --prefix) CFLAGS='$CFLAGS -std=gnu99'"

# Make commands
pack_cmd "make"
pack_cmd "make install"
