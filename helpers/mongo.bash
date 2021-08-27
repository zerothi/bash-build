v=2.7.3
add_package --build generic \
	    --package mongo \
	    --archive mongo-r$v.tar.gz \
	    https://github.com/mongodb/mongo/archive/r$v.tar.gz

pack_set -s $IS_MODULE -s $MAKE_PARALLEL

pack_set --host-reject $(get_hostname)

pack_set --install-query $(pack_get --prefix)/bin/mongo

pack_cmd "module load $(list -mod-names ++scons)"

# Install commands that it should run
pack_cmd "scons $(get_make_parallel) all"
pack_cmd "scons" \
	 "--prefix=$(pack_get --prefix)" \
	 "install"

pack_cmd "module unload $(list -mod-names ++scons)"
