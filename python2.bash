# Install Python 2 versions
# apt-get libbz2-dev libncurses5-dev zip libssl-dev
v=2.7.10
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

pack_set --install-query $(pack_get --prefix)/bin/python

if ! $(is_host ntch-) ; then
    pack_set --module-opt "--set-ENV PYTHONHOME=$(pack_get --prefix)"
fi

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
    "--enable-unicode=ucs4" \
    "LDFLAGS='$(list --LD-rp $(pack_get --mod-req) $lib_extra)'" \
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

if $(is_host n- slid muspel surt) ; then
    # The test of creating/deleting folders does not go well with 
    # NFS file systems. Hence we just skip one test to be able to test
    # everything else.
    msg_install --message "Skipping python tests..."
    #pack_cmd "make EXTRATESTOPTS='-x test_pathlib' test > tmp.test 2>&1"
	
else
    tmp=$(list -p '-x test_' urllib2_localnet)
    pack_cmd "make EXTRATESTOPTS='$tmp' test > tmp.test 2>&1"
fi
pack_cmd "make install"
if ! $(is_host n- slid muspel surt) ; then
    pack_set_mv_test tmp.test
fi

# Needed as it is not source_pack
pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias) 

# Install all relevant python packages

# The lookup name in the list for version number etc...
set_parent $(pack_get --alias)[$(pack_get --version)]
set_parent_exec python
# Install all python packages
source python-install.bash
clear_parent

# Initialize the module read path
old_path=$(build_get --module-path)
build_set --module-path $old_path-npa

create_module \
    -n "Nick Papior Andersen's basic python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.fireworks/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-RL ' fireworks)

create_module \
    -n "Nick Papior Andersen's basic python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.cython.numpy.scipy.numexpr.scientific.matplotlib/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-RL ' scientificpython scipy cython numexpr netcdf4py matplotlib)

create_module \
    -n "Nick Papior Andersen's parallel python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.cython.numpy.scipy.mpi4py.scientific/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-RL ' scientificpython scipy cython mpi4py netcdf4py)

create_module \
    -n "Nick Papior Andersen's parallel/numba python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.numpy.mpi4py.numba/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-RL ' numba mpi4py)

for i in $(get_index -all Inelastica-DEV) ; do
    create_module \
	-n "Nick Papior Andersen's Inelastica for: $(get_c)" \
	-v $(date +'%g-%j') \
	-M python$pV.Inelastica-DEV.$(pack_get --version $i)/$(get_c) \
	-P "/directory/should/not/exist" \
	$(list --prefix '-RL ' $i)
done

for i in $(get_index -all ase) ; do
    create_module \
	-n "Nick Papior Andersen's ASE for: $(get_c)" \
	-v $(date +'%g-%j') \
	-M python$pV.ase.$(pack_get --version $i)/$(get_c) \
	-P "/directory/should/not/exist" \
	$(list --prefix '-RL ' $i)
done

for i in $(get_index -all gpaw) ; do
    create_module \
	-n "Nick Papior Andersen's GPAW for: $(get_c)" \
	-v $(date +'%g-%j') \
	-M python$pV.gpaw.$(pack_get --version $i)/$(get_c) \
	-P "/directory/should/not/exist" \
	$(list --prefix '-RL ' $i)
done

create_module \
    -n "Nick Papior Andersen's parallel python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.kwant.$(pack_get --version kwant)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-RL ' kwant)

tmp=$(build_get --module-path)
rm -rf $tmp/python$pV.numerics/$(get_c)
tmp=
for i in scipy cython mpi4py netcdf4py matplotlib h5py numexpr sympy pandas theano sids ; do
    if [[ $(pack_installed $i) -eq 1 ]]; then
        tmp="$tmp $i"
    fi
done
create_module \
    -n "Nick Papior Andersen's parallel python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.numerics/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-RL ' $tmp)

if [[ $(pack_installed qutip) -eq 1 ]]; then
    create_module \
        -n "Nick Papior Andersen's Photonics python script for QuTip: $(get_c)" \
        -v $(date +'%g-%j') \
        -M python$pV.scientific.cython.numexpr.qutip/$(get_c) \
        -P "/directory/should/not/exist" \
        $(list --prefix '-RL ' scientificpython cython numexpr qutip)
fi

build_set --module-path $old_path

