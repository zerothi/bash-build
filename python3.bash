# Install Python 3 versions
# apt-get libbz2-dev libncurses5-dev zip
v=3.5.2
add_package --alias python --package python \
    http://www.python.org/ftp/python/$v/Python-$v.tar.xz
if $(is_host n-) ; then
    pack_set --package Python
fi

# The settings
pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set $(list --prefix '--mod-req ' zlib expat libffi)
lib_extra=
tmp_lib=
if [[ $(pack_get --installed sqlite) -eq 1 ]]; then
    lib_extra=sqlite
fi
if [[ $(pack_get --installed openssl) -eq 1 ]]; then
    lib_extra="$lib_extra openssl"
fi
if [[ $(pack_get --installed readline) -eq 1 ]]; then
    lib_extra="$lib_extra readline"
    if $(is_host nano pico femto atto) ; then
        tmp_lib="$tmp_lib -ltinfo"
    fi
fi

pack_set --install-query $(pack_get --prefix)/bin/python3

pCFLAGS="$CFLAGS"
tmp=
if $(is_c intel) ; then
    pCFLAGS="$CFLAGS -fomit-frame-pointer -fp-model precise -fp-model source"
    pFCFLAGS="$FCFLAGS -fomit-frame-pointer -fp-model precise -fp-model source"
    tmp="--without-gcc LANG=C AR=$AR CFLAGS='$pCFLAGS'"
elif ! $(is_c gnu) ; then
    tmp="--without-gcc"
fi

if [[ $(vrs_cmp 3.5.2 $v) -ge 0 ]]; then
    # We have to patch Python for openssl >= 1.1.0
    o=$(pwd_archives)/$(pack_get --package)-3.5-SSL-1.1.0.patch
    dwn_file https://bugs.python.org/file44360/Port-Python-s-SSL-module-to-OpenSSL-1.1.0-5.patch $o
    pack_cmd "pushd ../"
    pack_cmd "patch -p1 < $o ; echo FORCE"
    pack_cmd "popd"
fi

# Correct the UNIX C-compiler to GCC
pack_cmd "pushd ../Lib/distutils"
pack_cmd "sed -i -e 's/\"cc\"/\"gcc\"/g' unixccompiler.py"
pack_cmd "popd"


# Install commands that it should run
pack_cmd "../configure --with-threads" \
    "LDFLAGS='$(list --LD-rp $(pack_get --mod-req) $lib_extra) $tmp_lib'" \
    "CPPFLAGS='$(list --INCDIRS $(pack_get --mod-req) $lib_extra)' $tmp" \
    "--with-system-ffi --with-system-expat" \
    "--prefix=$(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"

# Common tests
if $(is_host n- surt muspel slid) ; then
    msg_install --message "Skipping python tests..."
    #pack_cmd "make EXTRATESTOPTS='-x test_pathlib' test > tmp.test 2>&1"
    
elif $(is_host nano pico femto) ; then
    tmp=$(list -p '-x test_' dbm httplib urllibnet urllib2_localnet gdb asyncio nntplib ssl multiprocessing_forkserver ssl)
    pack_cmd "make EXTRATESTOPTS='$tmp' test > tmp.test 2>&1"

elif $(is_host frontend) ; then
    tmp=$(list -p '-x test_' urllib2_localnet gdb gdbm asyncio httplib multiprocessing_forkserver ssl)
    pack_cmd "make EXTRATESTOPTS='$tmp' test > tmp.test 2>&1"

elif $(is_host atto) ; then
    tmp=$(list -p '-x test_' dbm httplib urllibnet urllib2_localnet gdb asyncio nntplib ssl multiprocessing_forkserver mailbox tarfile bz2)
    pack_cmd "make EXTRATESTOPTS='$tmp' test > tmp.test 2>&1 ; echo force"

else
    tmp=$(list -p '-x test_' urllib urllib2 urllib2net json ssl)
    pack_cmd "make EXTRATESTOPTS='$tmp' test > tmp.test 2>&1"
    
fi
pack_cmd "make install"
if ! $(is_host n- surt muspel slid) ; then
    pack_set_mv_test tmp.test
fi

# Assert that libpython$pV.a exists
# In certain cases libpython${pV}m.a 
# is created and we want to symlink the two
# as many libraries does not distinguish between the
# two.
tmp=libpython${v:0:3}
pack_cmd "if [ ! -e $(pack_get -LD)/${tmp}.a ]; then pushd $(pack_get -LD) ; ln -s ${tmp}m.a ${tmp}.a ; popd ; fi"


# Needed as it is not source_pack
pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n $(pack_get --alias).$(pack_get --version) \
    -W "Nick R. Papior script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias) 

# Install all relevant python packages

# The lookup name in the list for version number etc...
set_parent $(pack_get --alias)[$(pack_get --version)]
set_parent_exec python3
# Install all python packages
source python-install.bash
clear_parent

# Initialize the module read path
old_path=$(build_get --module-path)
build_set --module-path $old_path-npa

source python/python-mods.bash

build_set --module-path $old_path

exit 0
