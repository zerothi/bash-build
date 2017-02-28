v=0.7.0
add_package \
    --archive flook-$v.tar.gz \
    https://github.com/ElectronicStructureLibrary/flook/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libflookall.a

# Compile
pack_cmd "echo 'TOP_DIR=..' > setup.make"
pack_cmd "sed -i '$ a\
CC = $CC\n\
FC = $FC\n\
CFLAGS = $CFLAGS\n\
FCFLAGS = $FCFLAGS\n\
include ../Makefile' setup.make"

pack_cmd "make liball"

pack_cmd "make install PREFIX=$(pack_get --prefix)"
