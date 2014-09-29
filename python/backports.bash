add_package https://pypi.python.org/packages/source/b/backports.ssl_match_hostname/backports.ssl_match_hostname-3.4.0.2.tar.gz

pack_set --module-requirement $(get_parent)
pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/$(pack_get --package)-$(pack_get --version)-py$pV.egg

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix $(get_parent))"


