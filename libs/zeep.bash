v=5.1.6
add_package -package zeep -archive libzeep-$v.tar.gz \
	    https://github.com/mhekkel/libzeep/archive/v$v.tar.gz

pack_set -host-reject $(get_hostname)
pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libzeep.so
pack_set -lib -lzeep

pack_set -mod-req boost

pack_cmd "make BOOST=$(pack_get -prefix boost) PREFIX=$(pack_get -prefix)"
pack_cmd "make test > zeep.test 2>&1"
pack_cmd "make BOOST=$(pack_get -prefix boost) PREFIX=$(pack_get -prefix) install"
pack_store zeep.test

