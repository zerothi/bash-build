add_package --build generic http://prdownloads.sourceforge.net/flex/flex-2.5.37.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/flex

tmp="$(which flex 2>/dev/null)"
[ "${tmp:0:1}" == "/" ] && pack_set --host-reject $(get_hostname)

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
