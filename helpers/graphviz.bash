v=2.44.1
add_package -build generic \
            -archive graphviz-$v.tar.bz2 \
            https://gitlab.com/graphviz/graphviz/-/archive/$v/graphviz-$v.tar.bz2

pack_set -s $IS_MODULE

pack_set -module-opt "-lua-family graphviz"

pack_set -build-mod-req build-tools
pack_set -module-requirement gen-zlib
tmp=
if [[ $(pack_installed gts) -eq 1 ]]; then
    pack_set -module-requirement gts
    tmp="$tmp GTS_LIBS='$(list -LD-rp gts) -lgts'"
fi

pack_set -install-query $(pack_get -prefix)/bin/dot

pack_cmd "./autogen.sh"

pack_cmd "$tmp ./configure --with-x" \
	 "--prefix=$(pack_get -prefix)"

pack_cmd "make"
pack_cmd "make install"
