# apt-get install libpng(12)-dev libfreetype6-dev

v=2.2
add_package \
    --directory networkx-networkx-$v \
    https://github.com/networkx/networkx/archive/networkx-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py

pack_set --module-requirement matplotlib --module-requirement pandas

pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages/"

pack_cmd "$(get_parent_exec) setup.py config"
pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

add_test_package networkx.test
pack_cmd "unset LDFLAGS"
pack_cmd "pytest --pyargs networkx > $TEST_OUT 2>&1 ; echo 'Success'"
pack_store $TEST_OUT
