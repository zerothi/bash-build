v=0.7.0
add_package \
    https://github.com/zerothi/fdict/releases/download/v$v/fdict-$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --prefix)/lib/libfdict.a

# Create the arch-make file
file=setup.make
pack_cmd "echo '# Hello' > $file"
pack_cmd "sed -i '1 a\
FC = $FC\n\
FFLAGS = $FCFLAGS\n\
INCLUDES = -I.\n\
AR = $AR\n\
RANLIB = $RANLIB\n\
' $file"

pack_cmd "echo 'TOP_DIR=..' > Makefile"
pack_cmd "echo 'include ../Makefile' >> Makefile"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make test > fdict.test 2>&1 ; echo 'Fake success'"
pack_store fdict.test
pack_cmd "make PREFIX=$(pack_get --prefix) install"

