add_package --build generic http://ftp.gnu.org/gnu/bison/bison-3.0.4.tar.xz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/bison

pack_set --command "module load $(pack_get --module-name build-tools)"

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

pack_set --command "module unload $(pack_get --module-name build-tools)"
