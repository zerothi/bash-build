# apt-get install gettext
for v in 1.9.5 2.0.5 2.3.0 ; do
add_package --build generic \
	--archive git-$v.tar.gz \
	https://github.com/git/git/archive/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --module-requirement gen-zlib

pack_set --module-opt "--lua-family git"
pack_set --install-query $(pack_get --prefix)/bin/git

# Preload all tools for creating the configure script
tmp="$(pack_get --mod-req-all build-tools) $(pack_get --module-name build-tools)"
pack_set --command "module load $tmp"
pack_set --command "make configure"
pack_set --command "module unload $tmp"

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "CFLAGS='$CFLAGS $(list --LDFLAGS -Wlrpath gen-zlib)'" \
    --command-flag "--with-zlib=$(pack_get --prefix gen-zlib)" \
    --command-flag "--prefix=$(pack_get --prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
#pack_set --command "make test > tmp.test 2>&1"
pack_set --command "make install"
#pack_set_mv_test tmp.test

done

