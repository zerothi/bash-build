add_package --build generic http://ftp.gnu.org/gnu/automake/automake-1.14.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --module-requirement build-tools

p_V=$(pack_get --version)
c_V=`automake --version 2> /dev/null | head -1 | awk '{print $4}'`
[ -z "${c_V// /}" ] && c_V=1.1.1
if [ $(vrs_cmp $c_V $p_V) -eq 1 ]; then
    pack_set --host-reject "$(get_hostname)"
fi

pack_set --install-query $(pack_get --prefix build-tools)/bin/automake

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --prefix build-tools)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"
