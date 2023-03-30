# apt-get install libpng(12)-dev libfreetype6-dev
v=3.0
add_package \
    --directory networkx-networkx-$v \
    https://github.com/networkx/networkx/archive/networkx-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/networkx

pack_set --module-requirement matplotlib --module-requirement pandas

pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages/"

pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"

add_test_package networkx.test
pack_cmd "unset LDFLAGS"
pack_cmd "pytest --pyargs networkx > $TEST_OUT 2>&1 || echo forced"
pack_store $TEST_OUT
