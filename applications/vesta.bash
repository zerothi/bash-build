# Requirements:
#  apt-get install libglu1-mesa-dev mesa-common-dev lesstif2-dev tk8.5-dev libxmu-headers libxmu-dev
v=3.5.2
add_package -directory VESTA-gtk3 \
 	    -archive vesta-$v.tar.bz2 \
            https://jp-minerals.org/vesta/archives/$v/VESTA-gtk3.tar.bz2

pack_set -install-query $(pack_get -prefix)/bin/VESTA

pack_set -module-opt "-lua-family vesta"

pack_cmd "mkdir -p $(pack_get -prefix)/bin"
pack_cmd "cp -rf * $(pack_get -prefix)/bin/"
