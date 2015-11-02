# apt-get install gettext
for v in 2.6.2 ; do
add_package --build generic \
	    --archive git-$v.tar.gz \
	    https://github.com/git/git/archive/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --module-requirement gen-zlib

pack_set --module-opt "--lua-family git"
pack_set --install-query $(pack_get --prefix)/bin/git

# Preload all tools for creating the configure script
tmp="$(pack_get --mod-req-all build-tools) $(pack_get --module-name build-tools)"
pack_cmd "module load $tmp"
pack_cmd "make configure"
pack_cmd "module unload $tmp"

# Install commands that it should run
pack_cmd "./configure" \
	 "CFLAGS='$CFLAGS $(list --LD-rp gen-zlib)'" \
	 "--with-zlib=$(pack_get --prefix gen-zlib)" \
	 "--prefix=$(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
#pack_cmd "make test > tmp.test 2>&1"
pack_cmd "make install"
#pack_set_mv_test tmp.test

done

