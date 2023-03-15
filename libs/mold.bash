for v in 1.0.1
do
    add_package -archive mold-$v.tar.gz \
	https://github.com/rui314/mold/archive/refs/tags/v$v.tar.gz

    if $(is_intel) ; then
	pack_set --host-reject $(get_hostname)
    fi

    
    pack_set -s $IS_MODULE
    
    pack_set -install-query $(pack_get -prefix)/bin/mold
    
    pack_cmd "make CC=$CC CXX=$CXX CXXFLAGS='$CXXFLAGS -std=c++20'"
    pack_cmd "make PREFIX=$(pack_get -prefix) install"

done
