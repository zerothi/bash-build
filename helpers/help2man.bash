# Retrieve version of autoconf
add_package --build generic http://ftp.gnu.org/gnu/help2man/help2man-1.43.3.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

# This is a three tagged version
tmp=`help2man --version | head -1 | awk '{print $4}'`
[ -z "$tmp" ] && tmp=1.10.1
gv=${tmp%.*.*}
tmp=${tmp#*.}
lv=${tmp%.*}
mv=${tmp#*.}
[ $gv -gt 1 ] && pack_set --host-reject "$(get_hostname)"
[ $lv -gt 42 ] && pack_set --host-reject "$(get_hostname)"

pack_set --install-query $(pack_get --install-prefix)/bin/help2man

pack_set --module-opt "--set-ENV HELP2MAN=$(pack_get --install-prefix)/bin/help2man"

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

pack_install