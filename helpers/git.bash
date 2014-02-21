for v in 1.8.5.5 1.9.0 ; do
add_package --build generic \
	--archive git-$v.tar.gz \
	https://github.com/git/git/archive/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --module-requirement gen-zlib

pack_set --module-opt "--lua-family git"
pack_set --install-query $(pack_get --install-prefix)/bin/git

# Preload all tools for creating the configure script
pack_set --command "module load $(pack_get --module-requirement autoconf)" \
    --command-flag "$(pack_get --module-name autoconf)"
pack_set --command "make configure"
pack_set --command "module load $(pack_get --module-name autoconf)" \
    --command-flag "$(pack_get --module-requirement autoconf)"

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "CFLAGS='$CFLAGS $(list --LDFLAGS -Wlrpath gen-zlib)'" \
    --command-flag "--with-zlib=$(pack_get --install-prefix gen-zlib)" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make test > tmp.test 2>&1"
pack_set --command "make install"
pack_set --command "mv tmp.test $(pack_get --install-prefix)/"

pack_install

done

