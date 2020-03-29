add_package -package libpsml \
	    https://gitlab.com/siesta-project/libraries/libpsml/-/archive/libpsml-1.1.9/libpsml-libpsml-1.1.9.tar.bz2

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -LD)/libpsml.so

pack_set -build-mod-req build-tools
pack_set -module-requirement xmlf90
pack_set -lib -lpsml

pack_cmd "pushd .."
pack_cmd "autoreconf -i"
pack_cmd "popd"

pack_cmd "../configure" \
	 "--prefix $(pack_get -prefix)" \
	 "--with-xmlf90=$(pack_get -prefix xmlf90)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
