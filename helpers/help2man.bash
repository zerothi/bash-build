# Retrieve version of autoconf
add_package --build generic http://ftp.gnu.org/gnu/help2man/help2man-1.46.4.tar.xz

pack_set -s $MAKE_PARALLEL

pack_set --module-requirement build-tools

p_V=$(pack_get --version)
c_V=`help2man --version 2>/dev/null| head -1 | awk '{print $4}'`
[ -z "${c_V// /}" ] && c_V=1.1.1
if [ $(vrs_cmp $c_V $p_V) -eq 1 ]; then
    pack_set --host-reject "$(get_hostname)"
fi

pack_set --install-query $(pack_get --prefix build-tools)/bin/help2man

pack_set --module-opt "--set-ENV HELP2MAN=$(pack_get --prefix build-tools)/bin/help2man"

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --prefix build-tools)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"
