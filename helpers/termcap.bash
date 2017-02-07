add_package --build generic https://ftp.gnu.org/gnu/termcap/termcap-1.3.1.tar.gz

pack_set -s $IS_MODULE
pack_set --lib "-ltermcap"


pack_set --install-query $(pack_get --prefix)/lib/libtermcap.so

# Install commands that it should run
pack_cmd "./configure --prefix=$(pack_get --prefix)"

# Make commands
pack_cmd "make"
pack_cmd "make install"
