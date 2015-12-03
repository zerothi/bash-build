add_package http://bitspjoule.org/netpipe/code/NetPIPE-3.7.2.tar.gz

# What to check for when checking for installation...
pack_set --install-query $(pack_get --prefix otpo)/bin/NPmpi

pack_set --module-requirement mpi
pack_set --module-requirement otpo

# Make commands
pack_cmd "make mpi"

pack_cmd "cp NPmpi $(pack_get --prefix otpo)/bin/"
