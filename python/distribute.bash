# Install the distribute package locally
add_package http://pypi.python.org/packages/source/d/distribute/distribute-0.6.49.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/setuptools.pth

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix $(get_parent))"


