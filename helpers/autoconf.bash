add_package http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

tmp=`autoconf --version | head -1 | awk '{print $4}'`
[ -z "${tmp// /}" ] && tmp=1.1
gv=${tmp%.*}
lv=${tmp#*.}
[ $gv -gt 2 ] && pack_set --host-reject "$(get_hostname)"
[ $lv -gt 68 ] && pack_set --host-reject "$(get_hostname)"

pack_set --install-query $(pack_get --install-prefix)/bin/autoconf

[ $(pack_get --installed m4) -eq 1 ] && \
    pack_set --module-requirement m4

pack_set --module-opt "--set-ENV AUTOCONF=$(pack_get --install-prefix)/bin/autoconf"

pack_set --command "autoreconf -vi"

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

pack_install
