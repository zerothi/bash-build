[ $_mpi_version != "openmpi" ] && return
add_package --directory otpo \
    http://www.open-mpi.org/software/otpo/v1.0/downloads/otpo-1.0.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

# What to check for when checking for installation...
pack_set --install-query $(pack_get --prefix)/bin/otpo

pack_set --module-requirement mpi

pack_set --host-reject ntch-2

if ! $(is_c gnu) ; then
    pack_set --host-reject $(get_hostname)
fi

pack_set --command "module load $(pack_get --module-name build-tools)"
pack_set --command "./autogen.sh"

# Install commands that it should run
pack_set --command "./configure --prefix=$(pack_get --prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"
pack_set --command "cp OpenIB_Parameters $(pack_get --prefix)/"

pack_set --command "module unload $(pack_get --module-name build-tools)"
