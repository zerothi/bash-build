add_package http://www.student.dtu.dk/~nicpa/packages/m4-1.4.16.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

tmp=`m4 --version | head -1 | awk '{print $4}'`
gv=${tmp%.*.*}
tmp=${tmp#*.}
lv=${tmp%.*}
mv=${tmp#*.}
[ $gv -gt 1 ] && pack_set --host-reject "$(get_hostname)"
[ $lv -gt 4 ] && pack_set --host-reject "$(get_hostname)"
[ $mv -gt 15 ] && pack_set --host-reject "$(get_hostname)"

pack_set --install-query $(pack_get --install-prefix)/bin/m4

pack_set --command "./bootstrap"

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--enable-c++" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

pack_install