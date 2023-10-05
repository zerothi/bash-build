v=1.2.2
add_package https://github.com/mesonbuild/meson/releases/download/$v/meson-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -prefix)/bin/meson

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

# Install commands that it should run
pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"
pack_cmd "$_pip_cmd --target=$(pack_get -L)/python$pV/site-packages meson-python"

