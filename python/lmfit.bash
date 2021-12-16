v=1.0.3
add_package -directory lmfit-py-$v \
	https://files.pythonhosted.org/packages/8c/2f/8af90d45e585692eca1922c53e239c7aa97a904d9254df5b08f2f32520ac/lmfit-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set $(list --prefix ' --module-requirement ' scipy)

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/lmfit

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"

pack_cmd "unset LDFLAGS && $_pip_cmd . --prefix=$(pack_get -prefix)"
