# Install Python 2 versions
# apt-get libbz2-dev libncurses5-dev zip libssl-dev
v=2.7.15
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
tmp=
if [[ $(pack_get --installed sqlite) -eq 1 ]]; then
    lib_extra=sqlite
fi
if [[ $(pack_get --installed openssl) -eq 1 ]]; then
    pack_set --mod-req openssl[1.0.2]
    lib_extra="$lib_extra openssl[1.0.2]"
    tmp="--with-openssl=$(pack_get --prefix openssl[1.0.2])"
fi
if [[ $(pack_get --installed termcap) -eq 1 ]]; then
    lib_extra="$lib_extra termcap"
fi
if [[ $(pack_get --installed readline) -eq 1 ]]; then
    lib_extra="$lib_extra readline"
    if $(is_host nano pico femto) ; then
       tmp_lib="$tmp_lib -ltinfo"
    fi
fi

pack_set --install-query $(pack_get --prefix)/bin/python

if ! $(is_host ntch-) ; then
    pack_set --module-opt "--set-ENV PYTHONHOME=$(pack_get --prefix)"
fi

pCFLAGS="$CFLAGS"
if $(is_c intel) ; then
    pCFLAGS="$CFLAGS -fomit-frame-pointer -fp-model precise -fp-model source"
    pFCFLAGS="$FCFLAGS -fomit-frame-pointer -fp-model precise -fp-model source"
    tmp="$tmp --without-gcc --with-icc LANG=C AR=$AR CFLAGS='$pCFLAGS'"
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
#    enable shared build with: --enable-shared and adding python[$v] to list --LD-rp
pack_cmd "../configure" \
    "--enable-unicode=ucs4" \
    "LDFLAGS='$(list --LD-rp $(pack_get --mod-req) $lib_extra) $tmp_lib'" \
    "CPPFLAGS='$(list --INCDIRS $(pack_get --mod-req) $lib_extra)' $tmp" \
    "--with-system-ffi --with-system-expat" \
    "--prefix=$(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
# Clean up intel files (with old Intel compiler <= 13.0.1
# these tests does not pass due to unicode errors... :(
#if $(is_c intel) ; then
#    for f in Lib/test/test_unicode Lib/test/test_multibytecodec Lib/test/test_coding Lib/json/tests/test_unicode ; do
#    pack_cmd "rm -f ../$f.py"
#    done
#fi

if $(is_host n- sylg thul fjorm surt muspel slid) ; then
    # The test of creating/deleting folders does not go well with 
    # NFS file systems. Hence we just skip one test to be able to test
    # everything else.
    msg_install --message "Skipping python tests..."
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
    tmp=$(list -p '-x test_' urllib2_localnet distutils ssl)
    pack_cmd "make EXTRATESTOPTS='$tmp' test > python.test 2>&1"
    
fi
pack_cmd "make install"
if ! $(is_host n- sylg thul fjorm surt muspel slid) ; then
    pack_set_mv_test python.test
fi


# Needed as it is not source_pack
pack_install

create_module \
    --module-path $(build_get --module-path)-apps \
    -n $(pack_get --alias).$(pack_get --version) \
    -W "Script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias) 

# Install all relevant python packages

# The lookup name in the list for version number etc...
set_parent $(pack_get --alias)[$(pack_get --version)]
set_parent_exec $(pack_get --prefix)/bin/python2

# Install all python packages
source python-install.bash
clear_parent

# Initialize the module read path
old_path=$(build_get --module-path)
build_set --module-path $old_path-apps

# Create common modules
source python/python-mods.bash

build_set --module-path $old_path

