v=2.16
add_package --package pandoc --archive pandoc-$v.tar.gz \
    --version $v \
    https://github.com/jgm/pandoc/archive/$v.tar.gz

pack_set --host-reject $(get_hostname)

pack_set --install-query $(pack_get --prefix $(get_parent))/bin/pandoc

# Install commands that it should run
pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix $(get_parent))"
