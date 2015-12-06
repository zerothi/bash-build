add_package --build debug http://bitspjoule.org/netpipe/code/NetPIPE-3.7.2.tar.gz

# What to check for when checking for installation...
pack_set --install-query $(pack_get --prefix otpo)/bin/NPmpi

pack_set --module-requirement mpi
pack_set --module-requirement otpo

pack_cmd "sed -i -e 's:^\(CFLAGS\).*:\1 = $CFLAGS:' makefile"

# Make commands
pack_cmd "make mpi"

pack_cmd "cp NPmpi $(pack_get --prefix otpo)/bin/"
