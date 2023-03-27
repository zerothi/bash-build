add_package -build generic \
	    https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/7.1.0/graphviz-7.1.0.tar.xz

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
