# Requirements
#  apt-get install guile-2.0-dev
v=4.1.3
add_package https://github.com/stevengj/libctl/releases/download/v$v/libctl-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

if [[ $(pack_installed guile) -eq 1 ]]; then
   pack_set --module-requirement guile
fi

pack_set --install-query $(pack_get --LD)/libctl.a
pack_set --lib -lctl

# Install commands that it should run
pack_cmd "LIBS='-lm' ./configure --prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
