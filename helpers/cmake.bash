add_package --build generic https://cmake.org/files/v3.4/cmake-3.4.3.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

p_V=$(pack_get --version)
c_V=`cmake --version 2> /dev/null | head -1 | awk '{print $3}'`
[[ -z "${c_V// /}" ]] && c_V=1.1.1
if [[ $(vrs_cmp $c_V $p_V) -eq 1 ]]; then
    pack_set --host-reject "$(get_hostname)"
fi

pack_set --install-query $(pack_get --prefix)/bin/cmake

# Install commands that it should run
pack_cmd "./bootstrap" \
	 "--prefix=$(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
