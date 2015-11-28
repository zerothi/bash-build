add_package http://pstl.cs.uh.edu/projects/adcl-2.0.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

# What to check for when checking for installation...
pack_set --install-query $(pack_get --LD)/libadcl.a

pack_set --module-requirement mpi

pack_cmd "module load $(pack_get --module-name build-tools)"

# Install commands that it should run
pack_cmd "./configure --prefix=$(pack_get --prefix)" \
	 "--with-mpi-dir=$(pack_get --prefix mpi)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

pack_cmd "module unload $(pack_get --module-name build-tools)"
