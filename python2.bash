# Install Python 2 versions
# apt-get libbz2-dev libncurses5-dev zip libssl-dev
pV=2.7
IpV=$pV.16
add_package -alias python -package python \
    http://www.python.org/ftp/python/$IpV/Python-$IpV.tar.xz
if $(is_host n-) ; then
    pack_set -package Python
fi

# The settings
pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set $(list -prefix '-mod-req ' zlib expat)
if [[ $(pack_get -installed libffi) -eq 1 ]]; then
    pack_set -mod-req libffi
else
    pack_set -mod-req gen-libffi
fi
lib_extra=
tmp_lib=
tmp=
if [[ $(pack_get -installed sqlite) -eq 1 ]]; then
    lib_extra=sqlite
fi
if [[ $(pack_get -installed openssl) -eq 1 ]]; then
    lib_extra="$lib_extra openssl"
    pack_set -mod-req openssl
fi
if [[ $(pack_get -installed termcap) -eq 1 ]]; then
    lib_extra="$lib_extra termcap"
fi
if [[ $(pack_get -installed readline) -eq 1 ]]; then
    lib_extra="$lib_extra readline"
    if $(is_host nano pico femto) ; then
       tmp_lib="$tmp_lib -ltinfo"
    fi
fi

pack_set -install-query $(pack_get -prefix)/bin/python

pack_set -module-opt "-set-ENV PYTHONHOME=$(pack_get -prefix)"
pack_set -module-opt "-set-ENV PYTHONUSERBASE=~/.local/python-$IpV-$(get_c)"
pack_set -module-opt "-prepend-ENV PATH=~/.local/python-$IpV-$(get_c)/bin"

pCFLAGS="$CFLAGS"
if $(is_c intel) ; then
    pCFLAGS="$CFLAGS -fomit-frame-pointer -fp-model precise -fp-model source"
    pFCFLAGS="$FCFLAGS -fomit-frame-pointer -fp-model precise -fp-model source"
    tmp="$tmp --without-gcc --with-icc LANG=C AR=$AR CFLAGS='$pCFLAGS -std=c11'"
    tmp="$tmp --with-libm=-limf"
    # The clck library path has libutil.so which fucks up things!
    pack_cmd "unset LIBRARY_PATH"
elif $(is_c pgi) ; then
    pack_set -host-reject $(get_hostname)
elif ! $(is_c gnu) ; then
    tmp="$tmp --without-gcc"
fi

# Correct the UNIX C-compiler to GCC
pack_cmd "pushd ../Lib/distutils"
pack_cmd "sed -i -e 's/\"cc\"/\"gcc\"/g' unixccompiler.py"
pack_cmd "popd"


# Install commands that it should run
# When building non-shared it may break some builds.
# We could later build python with static linking and then
# later install the shared library (so that we both have .a and .so).
# For now we require that builds requiring a shared build is "fixed".
#    enable shared build with: --enable-shared and adding python[$IpV] to list -LD-rp
pack_cmd "../configure" \
    "--enable-unicode=ucs4" \
    "LDFLAGS='$(list -LD-rp $(pack_get -mod-req) $lib_extra) $tmp_lib'" \
    "CPPFLAGS='$(list -INCDIRS $(pack_get -mod-req) $lib_extra)' $tmp" \
    "--with-system-ffi --with-system-expat" \
    "--prefix=$(pack_get -prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"


if $(is_host n- sylg thul fjorm surt muspel slid) ; then
    # The test of creating/deleting folders does not go well with 
    # NFS file systems. Hence we just skip one test to be able to test
    # everything else.
    msg_install -message "Skipping python tests..."
    #pack_cmd "make EXTRATESTOPTS='-x test_pathlib' test > python.test 2>&1"

elif $(is_host nano pico femto) ; then
    tmp=$(list -p '-x test_' urllib2_localnet gdb)
    pack_cmd "make EXTRATESTOPTS='$tmp' test > python.test 2>&1"

elif $(is_host frontend) ; then
    tmp=$(list -p '-x test_' urllib2_localnet gdb gdbm)
    pack_cmd "make EXTRATESTOPTS='$tmp' test > python.test 2>&1"

elif $(is_host atto) ; then
    tmp=$(list -p '-x test_' urllib2_localnet gdb mailbox tarfile bz2 ssl)
    pack_cmd "make EXTRATESTOPTS='$tmp' test > python.test 2>&1"
    
else
    tmp=$(list -p '-x test_' urllib2_localnet distutils ssl httplib)
    pack_cmd "make EXTRATESTOPTS='$tmp' test > python.test 2>&1"
    
fi
pack_cmd "make install"
if ! $(is_host n- sylg thul fjorm surt muspel slid) ; then
    pack_store python.test
fi


# Create a new build with this module
new_build -name _internal-python$IpV \
    -module-path $(build_get -module-path)-python/$IpV \
    -source $(build_get -source) \
    $(list -prefix "-default-module " $(pack_get -mod-req-module) python[$IpV]) \
    -installation-path $(dirname $(pack_get -prefix $(get_parent)))/packages \
    -build-module-path "-package -version" \
    -build-installation-path "$IpV -package -version" \
    -build-path $(build_get -build-path)/py-$pV

mkdir -p $(build_get -module-path[_internal-python$IpV])-apps
build_set -default-setting[_internal-python$IpV] $(build_get -default-setting)

# Now add options to ensure that loading this module will enable the path for the *new build*
pack_set -module-opt "-use-path $(build_get -module-path[_internal-python$IpV])"
pack_set -module-opt "-use-path $(build_get -module-path[_internal-python$IpV])-apps"

# Needed as it is not source_pack
pack_install

# We should probably run
#  ensurepip (which ensures the correct pip and setuptools is installed)

create_module \
    -module-path $(build_get -module-path)-apps \
    -n $(pack_get -alias).$(pack_get -version) \
    -W "Script for loading $(pack_get -package): $(get_c)" \
    -v $(pack_get -version) \
    -M $(pack_get -alias).$(pack_get -version) \
    -P "/directory/should/not/exist" \
    $(list -prefix '-L ' $(pack_get -module-requirement)) \
    -L $(pack_get -alias)


# The lookup name in the list for version number etc...
set_parent $(pack_get -alias)[$(pack_get -version)]
set_parent_exec $(pack_get -prefix)/bin/python2

# Save the default build index
def_idx=$(build_get -default-build)
# Change to the new build default
build_set -default-build _internal-python$IpV


# Install all python packages
source python-install.bash
clear_parent

# Initialize the module read path
old_path=$(build_get -module-path)
build_set -module-path $old_path-apps
source python/python-mods.bash
build_set -module-path $old_path


# Reset default build
build_set -default-build $def_idx

exit 0
