add_package http://sourceforge.net/projects/pyparsing/files/pyparsing/pyparsing-1.5.7/pyparsing-1.5.7.tar.gz

pack_set --module-requirement $(get_parent)
pack_set --install-query $(pack_get --install-prefix $(get_parent))/lib/python$pV/site-packages/pyparsing.pyc

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix $(get_parent))"


