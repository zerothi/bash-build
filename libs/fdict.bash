v=0.4.3
add_package \
    --archive fdict-$v.tar.gz \
    https://github.com/zerothi/fdict/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/lib/libfdict.a

# Create the arch-make file
file=setup.make
pack_cmd "echo '# Hello' > $file"
pack_cmd "sed -i '1 a\
FC = $FC\n\
FC_SERIAL = $FC\n\
FFLAGS = $FCFLAGS\n\
AR = $AR\n\
' $file"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make test > tmp.test 2>&1 ; echo 'Fake success'"
pack_set_mv_test tmp.test
pack_cmd "make PREFIX=$(pack_get --prefix) install"

