v=1.3.7
add_package -archive bottleneck-$v.tar.gz \
	    https://github.com/pydata/bottleneck/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set $(list --prefix '--host-reject ' ntch)

# This devious thing will never install the same place
pack_set --install-query $(pack_get --LD)/python$pV/site-packages
pack_cmd "mkdir -p $(pack_get --install-query)"

# Add requirments when creating the module
pack_set $(list --prefix ' --module-requirement ' numpy cython)

pack_cmd "$_pip_cmd . --prefix=$(pack_get --prefix)"
