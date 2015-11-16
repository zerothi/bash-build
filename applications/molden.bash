# Install molden
# apt-get install libglu1-mesa-dev libx11-dev mesa-common-dev
add_package --build generic-host ftp://ftp.cmbi.ru.nl/pub/molgraph/molden/molden5.4.tar.gz

#pack_set --directory molden5.2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $CRT_DEF_MODULE

pack_set --module-opt "--lua-family molden"
pack_set --install-query "$(pack_get --prefix)/bin/molden"

pack_cmd "sed -i -e 's/CC[[:space:]]*=.*/CC = $CC/g' makefile"
pack_cmd "sed -i -e 's/FC[[:space:]]*=.*/FC = $FC/g' makefile"

pack_cmd "mkdir -p $(pack_get --prefix)/bin/"

pack_cmd "make $(get_make_parallel) molden"
pack_cmd "cp molden $(pack_get --prefix)/bin/"
if $(is_host surt thul muspel slid) || $(is_host zeroth) ; then
    pack_cmd "echo Will not make gmolden"
else
    pack_cmd "make $(get_make_parallel) gmolden"
    pack_cmd "cp gmolden $(pack_get --prefix)/bin/"
fi
