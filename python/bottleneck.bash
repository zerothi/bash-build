# 1.0.0 requires numpy >= 1.9.1
v=1.3.2
add_package -archive bottleneck-$v.tar.gz \
	    https://github.com/pydata/bottleneck/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set $(list --prefix '--host-reject ' ntch)

# This devious thing will never install the same place
pack_set --install-query $(pack_get --LD)/python$pV/site-packages
pack_cmd "mkdir -p $(pack_get --install-query)"

# Add requirments when creating the module
pack_set $(list --prefix ' --module-requirement ' numpy cython)

pack_cmd "$(get_parent_exec) setup.py build"

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)" \
