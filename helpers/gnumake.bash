add_package --build generic ftp://ftp.gnu.org/gnu/make/make-4.4.1.tar.lz

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR

pack_set --prefix $(pack_get --prefix build-tools)

pack_set --install-query $(pack_get --prefix)/bin/make

p_V=$(pack_get --version)
c_V=`make --version 2>/dev/null | head -1 | awk '{print $3}'`
[[ -z "${c_V// /}" ]] && c_V=1.1.1
if [[ $(vrs_cmp $c_V $p_V) -ge 0 ]]; then
    pack_set -host-reject "$(get_hostname)"
fi

if [[ $(vrs_cmp $p_V 4.2.1) -eq 0 ]]; then
    if $(is_host nicpa) ; then
	o=$(pwd_archives)/$(pack_get -package)-$(pack_get -version)-patch
	dwn_file https://raw.githubusercontent.com/osresearch/heads/make-4.2.1/patches/make-4.2.1.patch $o
	#    pack_cmd "pushd .. ; patch -p1 < $o ; popd"
    fi
    pack_cmd "sed -s -i -e 's:_GNU_GLOB_INTERFACE_VERSION ==:_GNU_GLOB_INTERFACE_VERSION >=:g' ../configure ../glob/glob.c"
fi

pack_cmd "../configure --prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
