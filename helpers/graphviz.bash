v=2.40.1
add_package --build generic \
	    --directory graphviz-stable_release_$v \
            --archive graphviz-$v.tar.bz2 \
            https://gitlab.com/graphviz/graphviz/-/archive/stable_release_$v/graphviz-stable_release_$v.tar.bz2

pack_set -s $IS_MODULE

pack_set --module-opt "--lua-family graphviz"

pack_set --module-requirement gen-zlib
tmp=
if [[ $(pack_installed gts) -eq 1 ]]; then
    pack_set --module-requirement gts
    tmp="$tmp GTS_LIBS='$(list -LD-rp gts) -lgts'"
fi

pack_set --install-query $(pack_get --prefix)/bin/dot

pack_cmd "module load build-tools"
pack_cmd "./autogen.sh"

pack_cmd "$tmp ./configure --with-x" \
	 "--prefix=$(pack_get --prefix)"

pack_cmd "make"
pack_cmd "make install"

pack_cmd "module unload build-tools"
