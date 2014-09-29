v=1.6
add_package \
    --archive pygments-$v.bz2 \
    https://bitbucket.org/birkenfeld/pygments-main/get/$v.tar.bz2

pack_set --directory "birkenfeld-pygments*"

pack_set --install-query $(pack_get --prefix $(get_parent))/bin/pygmentize

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix $(get_parent))"
