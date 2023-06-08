v=0.13.1
add_package -archive pythran-$v.tar.gz \
	    https://github.com/serge-sans-paille/pythran/archive/refs/tags/$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/pythran

pack_set $(list -prefix ' -module-requirement ' numpy)

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"
pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"
