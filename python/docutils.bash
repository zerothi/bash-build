add_package https://pypi.python.org/packages/source/d/docutils/docutils-0.18.tar.gz

pack_set --module-requirement $(get_parent)
pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/docutils

pack_cmd "$_pip_cmd . --prefix=$(pack_get --prefix $(get_parent))"


