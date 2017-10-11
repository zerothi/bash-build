add_package --build generic ftp://ftp.gnu.org/gnu/make/make-4.2.1.tar.bz2

pack_set -s $MAKE_PARALLEL

pack_set --prefix $(pack_get --prefix build-tools)

pack_set --install-query $(pack_get --prefix)/bin/make

p_V=$(pack_get --version)
c_V=`make --version 2>/dev/null | head -1 | awk '{print $3}'`
[[ -z "${c_V// /}" ]] && c_V=1.1.1
if [[ $(vrs_cmp $c_V $p_V) -eq 1 ]]; then
    pack_set --host-reject "$(get_hostname)"
fi

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
