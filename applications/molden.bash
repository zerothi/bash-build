# Install grace, which is a simple library
add_package ftp://ftp.cmbi.ru.nl/pub/molgraph/molden/molden5.0.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/molden


pack_set --command "sed -i -e 's/CC[[:space:]]*=.*/CC = $CC/g' makefile"
pack_set --command "sed -i -e 's/FC[[:space:]]*=.*/FC = $FC/g' makefile"

# Make commands
pack_set --command "make $(get_make_parallel) molden"
pack_set --command "make $(get_make_parallel) gmolden"

# Install the package
pack_set --command "mkdir -p $(pack_get --install-prefix)/bin/"
pack_set --command "cp molden $(pack_get --install-prefix)/bin/"
pack_set --command "cp gmolden $(pack_get --install-prefix)/bin/"

pack_install