if [[ $(vrs_cmp $(get_c -version) 4.5.0) -lt 0 ]]; then
    # This is the latest cmake release without C++ 11 requirements
    add_package -build generic https://cmake.org/files/v3.9/cmake-3.9.6.tar.gz
else
    add_package -build generic https://cmake.org/files/v3.14/cmake-3.14.4.tar.gz
fi
pack_set -s $MAKE_PARALLEL

pack_set -prefix $(pack_get -prefix build-tools)
pack_set -build-mod-req build-tools

p_V=$(pack_get -version)
c_V=`cmake --version 2> /dev/null | head -1 | awk '{print $3}'`
[[ -z "${c_V// /}" ]] && c_V=1.1.1
if [[ $(vrs_cmp $c_V $p_V) -eq 1 ]]; then
    pack_set -host-reject "$(get_hostname)"
fi

pack_set -install-query $(pack_get -prefix)/bin/cmake

pack_cmd "./bootstrap --prefix=$(pack_get -prefix)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
