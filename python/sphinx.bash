v=6.1.3
add_package --archive sphinx-$v.tar.gz \
    https://github.com/sphinx-doc/sphinx/archive/$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/Sphinx-$(pack_get --version)-py$pV.egg

pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix $(get_parent))"
