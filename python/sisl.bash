if [[ "x${pV:0:1}" == "x3" ]]; then
    v=0.12.1
else
    v=0.9.8
fi
add_package -archive sisl-$v.tar.gz \
    https://github.com/zerothi/sisl/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/sisl

pack_set -build-mod-req cython
pack_set $(list -prefix ' -module-requirement ' scipy netcdf4py)

pack_cmd "mkdir -p $(pack_get -prefix)/lib/python$pV/site-packages"

pack_cmd "unset LDFLAGS && $_pip_cmd . --prefix=$(pack_get -prefix)"

add_test_package sisl.test
pack_cmd "unset LDFLAGS"
pack_cmd "pytest --pyargs sisl > $TEST_OUT 2>&1 || echo forced"
pack_store $TEST_OUT
