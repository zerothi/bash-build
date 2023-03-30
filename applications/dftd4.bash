v=3.5.0
add_package --archive dftd4-$v.tar.gz \
	    https://github.com/dftd4/dftd4/archive/v$v.tar.gz

pack_set -host-reject $(get_hostname)
pack_set -build-mod-req meson
pack_set -build-mod-req build-tools

pack_set -install-query $(pack_get -prefix)/bin/dftd4

pack_cmd "meson setup build --prefix $(pack_get -prefix)"
pack_cmd "ninja -C build"
pack_cmd "ninja -C install"

