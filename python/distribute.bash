add_package http://pypi.python.org/packages/source/d/distribute/distribute-0.7.3.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/setuptools.pth

pack_cmd "$_pip_cmd . --prefix=$(pack_get --prefix $(get_parent))"
