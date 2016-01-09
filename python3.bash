# Install Python 3 versions
# apt-get libbz2-dev libncurses5-dev zip
v=3.5.1
add_package --alias python --package python \
    http://www.python.org/ftp/python/$v/Python-$v.tar.xz
if $(is_host n-) ; then
    pack_set --package Python
fi

# The settings
pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set $(list --prefix '--mod-req ' zlib expat libffi)
lib_extra=
if [[ $(pack_get --installed sqlite) -eq 1 ]]; then
    lib_extra=sqlite
fi
if [[ $(pack_get --installed openssl) -eq 1 ]]; then
    lib_extra="$lib_extra openssl"
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

# Install commands that it should run
pack_cmd "../configure --with-threads" \
    "LDFLAGS='$(list --LD-rp $(pack_get --mod-req) $lib_extra)'" \
    "CPPFLAGS='$(list --INCDIRS $(pack_get --mod-req) $lib_extra)' $tmp" \
    "--with-system-ffi --with-system-expat" \
    "--prefix=$(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"

if $(is_host n- surt muspel slid) ; then
    msg_install --message "Skipping python tests..."
    #pack_cmd "make EXTRATESTOPTS='-x test_pathlib' test > tmp.test 2>&1"
else
    tmp=$(list -p '-x test_' urllib urllib2 urllib2net json)
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

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick R. Papior script for loading $(pack_get --package): $(get_c)" \
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
