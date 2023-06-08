v=3.8.0
add_package \
    -package pytables \
    -archive PyTables-$v.tar.gz \
    https://github.com/PyTables/PyTables/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -prefix)/bin/ptdump

pack_set -build-mod-req cython
# Add requirments when creating the module
pack_set -mod-req hdf5-serial -mod-req numexpr \
	-mod-req py-blosc2 -mod-req py-blosc

if [[ $(vrs_cmp 3.1.1 $v) -le 0 ]]; then
    pack_cmd "sed -i -e 's:Cython.Compiler.Main:Cython.Compiler:' setup.py"
fi

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages/"
pack_cmd "sed -i -e 's:library_path = None:library_path = Path(\"$(pack_get -LD blosc2)\"):' setup.py"
opts=
opts="$opts --config-settings=--hdf5=$(pack_get -prefix hdf5-serial)"
opts="$opts --config-settings=--blosc=$(pack_get -prefix blosc)"
opts="$opts --config-settings=--blosc2=$(pack_get -prefix blosc2)"
opts="$opts --config-settings=--cflags='${pCFLAGS//-march=native/} -pthread'"
pack_cmd "$_pip_cmd . $opts --prefix=$(pack_get -prefix)"
