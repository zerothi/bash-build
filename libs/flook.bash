v=0.8.1
add_package -archive flook-$v.tar.gz \
   https://github.com/ElectronicStructureLibrary/flook/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libflookall.a

# Compile
pack_cmd "unset BIN_DIR"
pack_cmd "echo '# NRP setup.make' > setup.make"
pack_cmd "sed -i '$ a\
PLATFORM = linux\n\
CC = $CC\n\
FC = $FC\n\
CFLAGS = $CFLAGS\n\
FCFLAGS = $FCFLAGS\n' setup.make"

# Create makefile
pack_cmd "echo 'TOP_DIR=..' > Makefile"
pack_cmd "echo 'include ../Makefile' >> Makefile"

pack_cmd "make liball"

pack_cmd "make install PREFIX=$(pack_get --prefix)"
