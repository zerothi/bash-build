v=1.0.3
add_package --archive lmfit-$v.tar.gz --directory lmfit-py-$v \
	    https://github.com/lmfit/lmfit-py/archive/$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set $(list --prefix ' --module-requirement ' scipy)

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/lmfit

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"

pack_cmd "unset LDFLAGS && $_pip_cmd . --prefix=$(pack_get -prefix)"
