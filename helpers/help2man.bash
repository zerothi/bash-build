# Retrieve version of autoconf
add_package --build generic http://ftp.gnu.org/gnu/help2man/help2man-1.48.5.tar.xz

pack_set -s $MAKE_PARALLEL

pack_set --module-requirement build-tools
pack_set --prefix $(pack_get --prefix build-tools)

p_V=$(pack_get --version)
c_V=`help2man --version 2>/dev/null| head -1 | awk '{print $4}'`
[[ -z "${c_V// /}" ]] && c_V=1.1.1
if [[ $(vrs_cmp $c_V $p_V) -eq 1 ]]; then
    pack_set --host-reject "$(get_hostname)"
fi

pack_set --install-query $(pack_get --prefix)/bin/help2man

pack_set --module-opt "--set-ENV HELP2MAN=$(pack_get --prefix)/bin/help2man"

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
