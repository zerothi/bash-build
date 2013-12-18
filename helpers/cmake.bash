add_package --build generic http://www.cmake.org/files/v2.8/cmake-2.8.12.1.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

p_V=$(pack_get --version)
c_V=`cmake --version 2> /dev/null | head -1 | awk '{print $3}'`
[ -z "${c_V// /}" ] && c_V=1.1.1
if [ $(vrs_cmp $c_V $p_V) -eq 1 ]; then
    pack_set --host-reject "$(get_hostname)"
fi

pack_set --install-query $(pack_get --install-prefix)/bin/cmake

# Install commands that it should run
pack_set --command "./bootstrap" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

pack_install
