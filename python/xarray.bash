# 0.11.3 and onwards are Py3 only!
if [[ "x${pV:0:1}" == "x3" ]]; then
    v=0.16.0
else
    v=0.11.3
fi
add_package \
    -archive xarray-$v.tar.gz \
    https://github.com/pydata/xarray/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/xarray

pack_set $(list --prefix ' -module-requirement ' pandas netcdf4py dask)
if [[ $(pack_installed bottleneck) -eq 1 ]]; then
    pack_set -module-requirement bottleneck
fi
if [[ $(pack_installed seaborn) -eq 1 ]]; then
    pack_set -module-requirement seaborn
fi

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_cmd "echo 'Version: $v' > PKG-INFO"
pack_cmd "sed -i -e 's/packages = xarray/packages = find:/' setup.cfg"
pack_cmd "pip install $pip_install_opts --prefix=$(pack_get -prefix) ."

add_test_package xarray.test
pack_cmd "pytest --pyargs xarray > $TEST_OUT 2>&1 || echo forced"
pack_store $TEST_OUT
