add_package --build generic http://ftpmirror.gnu.org/libtool/libtool-2.4.3.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --module-requirement build-tools

p_V=$(pack_get --version)
c_V=`libtool --version 2>/dev/null | head -1 | awk '{print $4}'`
[ -z "${c_V// /}" ] && c_V=1.1.1
if [ $(vrs_cmp $c_V $p_V) -eq 1 ]; then
    pack_set --host-reject "$(get_hostname)"
fi

pack_set --install-query $(pack_get --prefix build-tools)/bin/libtool

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --prefix build-tools)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"
