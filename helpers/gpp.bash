v=2.24
add_package --archive gpp-$v.tar.gz \
	    https://github.com/logological/gpp/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/gpp

# First create the configure command
pack_cmd "module load $(pack_get --module-name build-tools)"

pack_cmd "touch ChangeLog"
pack_cmd "autoreconf --install ; echo ''"

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel) ; echo ''"
pack_cmd "make install ; echo ''"

pack_cmd "module unload $(pack_get --module-name build-tools)"
