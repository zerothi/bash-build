v=1.76.0
add_package --package gen-boost \
    --version $v \
    http://downloads.sourceforge.net/project/boost/boost/$v/boost_${v//./_}.tar.bz2

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libboost_random.a

pack_cmd "./bootstrap.sh" \
	 "--with-libraries=all" \
	 "--without-libraries=python" \
	 "--prefix=$(pack_get --prefix)" \
	 "--includedir=$(pack_get --prefix)/include" \
	 "--libdir=$(pack_get --LD)"

# Make commands
pack_cmd "./b2 --build-dir=build-tmp --without-python stage"
pack_cmd "./b2 --build-dir=build-tmp --without-python install --prefix=$(pack_get --prefix)"

