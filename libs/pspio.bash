v=0.2.4
add_package -package pspio https://gitlab.com/ElectronicStructureLibrary/libpspio/-/archive/$v/libpspio-$v.tar.bz2

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libpspio.a

pack_set -build-mod-req build-tools
pack_set --module-requirement gsl

pack_set --lib -lpspiof -lpspio

# bug-fix for Py3 and above
pack_cmd "sed -i -e 's/file(/open(/g' ../fortran/scripts/make-fortran-constants.py"
pack_cmd "pushd .. ; ./autogen.sh ; popd"
pack_cmd "../configure" \
	 "--enable-fortran" \
	 "--enable-gsl" \
	 "--with-gsl=$(pack_get --prefix gsl)" \
	 "--prefix $(pack_get --prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
