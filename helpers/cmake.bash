for v in 2.8.12.2 3.13.5 3.14.7
do

    if [[ $(vrs_cmp $(get_c -version) 4.5.0) -lt 0 ]]; then
	if [[ $(vrs_cmp $v 3.9.6) -gt 0 ]]; then
	    continue
	fi
    fi

    if $(is_host nicpa) ; then
	pack_set -host-reject $(get_hostname)
    fi
    
    add_package -build generic https://cmake.org/files/v$(str_version -1 $v).$(str_version -2 $v)/cmake-$v.tar.gz
    pack_set -s $MAKE_PARALLEL -s $IS_MODULE
    
    pack_set -build-mod-req build-tools
    pack_set -install-query $(pack_get -prefix)/bin/cmake
    
    pack_cmd "./bootstrap --prefix=$(pack_get -prefix)"
    pack_cmd "make $(get_make_parallel)"
    pack_cmd "make install"

done
