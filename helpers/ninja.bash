v=1.8.2
add_package --directory . \
	    --archive ninja-$v.zip \
	    https://github.com/ninja-build/ninja/releases/download/v$v/ninja-linux.zip

pack_set --module-requirement build-tools
pack_set --prefix $(pack_get --prefix build-tools)

pack_set --install-query $(pack_get --prefix)/bin/ninja

pack_cmd "mv ninja $(pack_get --prefix)/bin/"
pack_cmd "chmod a+x $(pack_get --prefix)/bin/ninja"

