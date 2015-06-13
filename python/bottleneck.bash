# 1.0.0 requires numpy >= 1.9.1
v=1.0.0
add_package --package bottleneck \
    https://pypi.python.org/packages/source/B/Bottleneck/Bottleneck-$v.tar.gz

pack_set -s $IS_MODULE

pack_set $(list --prefix '--host-reject ' ntch)

# This devious thing will never install the same place
pack_set --install-query $(pack_get --LD)/python$pV/site-packages

# Add requirments when creating the module
pack_set $(list --prefix ' --module-requirement ' numpy cython)

pack_set --command "$(get_parent_exec) setup.py build"

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)" \
