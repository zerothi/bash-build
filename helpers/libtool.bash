add_package --build generic http://ftpmirror.gnu.org/libtool/libtool-2.4.2.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

p_V=$(pack_get --version)
c_V=`libtool --version 2>/dev/null | head -1 | awk '{print $4}'`
[ -z "${c_V// /}" ] && c_V=1.1.1
if [ $(vrs_cmp $c_V $p_V) -eq 1 ]; then
    pack_set --host-reject "$(get_hostname)"
fi

pack_set --install-query $(pack_get --prefix)/bin/libtool

[ $(pack_installed automake) -eq 1 ] && \
    pack_set --module-requirement automake

[ $(pack_installed autoconf) -eq 1 ] && \
    pack_set --module-requirement autoconf

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

pack_install
