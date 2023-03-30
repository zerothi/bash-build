v=2.51.0
add_package -archive dvc-$v.tar.gz \
	    https://github.com/iterative/dvc/archive/$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/dvc

pack_set $(list --prefix ' --module-requirement ' numpy cython scipy matplotlib)

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_cmd "unset LDFLAGS && $_pip_cmd . --prefix=$(pack_get -prefix)"

