# Install Python 2 versions
# apt-get bz2-dev
v=2.7.8
if $(is_host n-) ; then
    add_package --alias python --package Python \
	http://www.python.org/ftp/python/$v/Python-$v.tgz
else
    add_package --alias python --package python \
	http://www.python.org/ftp/python/$v/Python-$v.tgz
fi

# The settings
pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --module-requirement zlib \
    --module-requirement expat \
    --module-requirement libffi

pack_set --install-query $(pack_get --install-prefix)/bin/python

pack_set --module-opt "--set-ENV PYTHONHOME=$(pack_get --prefix)"
if $(is_host eris) ; then
    pack_set --module-opt "--prepend-ENV PYTHONPATH=$(pack_get --prefix)/lib64/python2.7/lib-dynload"
fi

pCFLAGS="$CFLAGS"
tmp=
if $(is_c intel) ; then
    pCFLAGS="$CFLAGS -fomit-frame-pointer -fp-model strict"
    pFCFLAGS="$FCFLAGS -fomit-frame-pointer -fp-model strict"
    tmp="--without-gcc LANG=C AR=$AR CFLAGS='$pCFLAGS'"
elif ! $(is_c gnu) ; then
    tmp="--without-gcc"
fi

# Install commands that it should run
pack_set --command "../configure --with-threads" \
    --command-flag "--enable-unicode=ucs4" \
    --command-flag "LDFLAGS='$(list --LDFLAGS --Wlrpath zlib expat libffi)'" \
    --command-flag "CPPFLAGS='$(list --INCDIRS zlib expat libffi)' $tmp" \
    --command-flag "--with-system-ffi --with-system-expat" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
# Clean up intel files (with old Intel compiler <= 13.0.1
# these tests does not pass due to unicode errors... :(
#if $(is_c intel) ; then
#    for f in Lib/test/test_unicode Lib/test/test_multibytecodec Lib/test/test_coding Lib/json/tests/test_unicode ; do
#    pack_set --command "rm -f ../$f.py"
#    done
#fi

if $(is_host n- slid muspel surt hemera eris) ; then
    # The test of creating/deleting folders does not go well with 
    # NFS file systems. Hence we just skip one test to be able to test
    # everything else.
    echo "Skipping python tests..."
    #pack_set --command "make EXTRATESTOPTS='-x test_pathlib' test > tmp.test 2>&1"
	
else
    pack_set --command "make test > tmp.test 2>&1"
fi
pack_set --command "make install"
if ! $(is_host n- slid muspel surt hemera eris) ; then
    pack_set_mv_test tmp.test
fi

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
    $(list --prefix '-L ' $(pack_get --module-requirement fireworks) fireworks)

create_module \
    -n "Nick Papior Andersen's basic python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.cython.numpy.scipy.numexpr.scientific.matplotlib/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement scientificpython scipy cython numexpr matplotlib) scientificpython scipy cython numexpr matplotlib)

create_module \
    -n "Nick Papior Andersen's parallel python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.cython.mpi4py.numpy.scipy.scientific/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement scientificpython scipy mpi4py) scientificpython scipy cython mpi4py)

create_module \
    -n "Nick Papior Andersen's parallel OPT python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.mpi4py.numba.numpy/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement numba mpi4py) numba mpi4py)

for i in $(get_index -all Inelastica-DEV) ; do
    create_module \
	-n "Nick Papior Andersen's Inelastica for: $(get_c)" \
	-v $(date +'%g-%j') \
	-M python$pV.Inelastica-DEV.$(pack_get --version $i)/$(get_c) \
	-P "/directory/should/not/exist" \
	$(list --prefix '-L ' $(pack_get --module-requirement $i) $i)
done

for i in $(get_index -all ase) ; do
    create_module \
	-n "Nick Papior Andersen's ASE for: $(get_c)" \
	-v $(date +'%g-%j') \
	-M python$pV.ase.$(pack_get --version $i)/$(get_c) \
	-P "/directory/should/not/exist" \
	$(list --prefix '-L ' $(pack_get --module-requirement $i) $i)
done

for i in $(get_index -all gpaw) ; do
    create_module \
	-n "Nick Papior Andersen's GPAW for: $(get_c)" \
	-v $(date +'%g-%j') \
	-M python$pV.gpaw.$(pack_get --version $i)/$(get_c) \
	-P "/directory/should/not/exist" \
	$(list --prefix '-L ' $(pack_get --module-requirement $i) $i)
done

create_module \
    -n "Nick Papior Andersen's parallel python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.kwant.$(pack_get --version kwant)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement kwant) kwant)

if [ $(pack_get --installed qutip) -eq 1 ]; then
    create_module \
        -n "Nick Papior Andersen's Photonics python script for QuTip: $(get_c)" \
        -v $(date +'%g-%j') \
        -M python$pV.scientific.cython.numexpr.qutip/$(get_c) \
        -P "/directory/should/not/exist" \
        $(list --prefix '-L ' $(pack_get --module-requirement scientificpython qutip numexpr) scientificpython cython numexpr qutip)
fi

build_set --module-path $old_path

