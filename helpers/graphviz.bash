add_package --build generic \
    http://graphviz.org/pub/graphviz/stable/SOURCES/graphviz-2.38.0.tar.gz

pack_set -s $IS_MODULE

pack_set $(list --prefix "--host-reject " surt muspel slid hemera eris)

pack_set --module-opt "--lua-family graphviz"

pack_set --module-requirement gen-zlib

pack_set --install-query $(pack_get --prefix)/bin/dot

pack_set --command "./configure --with-x" \
    --command-flag "--prefix=$(pack_get --prefix)"

pack_set --command "make"
pack_set --command "make install"

pack_install
