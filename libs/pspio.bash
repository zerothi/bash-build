v=0.2.4
add_package https://gitlab.com/ElectronicStructureLibrary/libpspio/-/archive/$v/libpspio-$v.tar.bz2

pack_set -s $IS_MODULE -s $BUILD_DIR -s $BUILD_TOOLS

pack_set --install-query $(pack_get --LD)/libpspio.a

pack_set --module-requirement gsl

pack_set --lib -lpspiof -lpspio

pack_cmd "pushd .. ; ./autogen.sh ; popd"
pack_cmd "../configure" \
	 "--enable-fortran" \
	 "--enable-gsl" \
	 "--with-gsl=$(pack_get --prefix gsl)" \
	 "--prefix $(pack_get --prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
