# Requirements:
#  apt-get install libglu1-mesa-dev mesa-common-dev lesstif2-dev tk8.5-dev libxmu-headers libxmu-dev

add_package --directory VESTA-x86_64 \
	    --archive vesta-3.4.4.tar.bz2 \
	    http://www.geocities.jp/kmo_mma/crystal/download/VESTA-x86_64.tar.bz2

pack_set --install-query $(pack_get --prefix)/bin/VESTA

pack_set --module-opt "--lua-family vesta"

# Install commands that it should run
pack_cmd "mkdir -p $(pack_get --prefix)/bin"
pack_cmd "cp -rf * $(pack_get --prefix)/bin/"
