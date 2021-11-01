add_package --package pygments \
    https://pypi.python.org/packages/source/P/Pygments/Pygments-2.10.0.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/bin/pygmentize

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"
