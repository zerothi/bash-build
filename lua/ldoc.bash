v=1.4.6
add_package --build generic \
	    --package ldoc \
	    --archive LDoc-$v.tar.gz \
	    https://github.com/lunarmodules/LDoc/archive/$v.tar.gz

pack_set --module-requirement penlight

pack_set --install-query $(pack_get --prefix lua)/bin/ldoc

pack_cmd "make install"

