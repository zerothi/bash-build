v=1.4.6
add_package --build generic \
	    --package ldoc \
	    --archive LDoc-$v.tar.gz \
	    https://github.com/stevedonovan/LDoc/archive/$v.tar.gz

pack_set --module-requirement penlight

pack_set --install-query $(pack_get --prefix)/bin/ldoc

pack_cmd "make install"

