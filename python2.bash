# Install Python 2 versions
v=2.7.6
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

tmp=
if ! $(is_c gnu) ; then
    tmp="--without-gcc"
fi

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "LDFLAGS='$(list --LDFLAGS --Wlrpath zlib expat libffi)'" \
    --command-flag "CPPFLAGS='$(list --INCDIRS zlib expat libffi)' $tmp" \
    --command-flag "--with-system-ffi --with-system-expat" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
# Clean up intel files
if $(is_c intel) ; then
    for f in Lib/test/test_unicode Lib/test/test_multibytecodec Lib/test/test_coding Lib/json/tests/test_unicode ; do
    pack_set --command "rm $f.py"
    done
fi

#pack_set --command "make test > tmp.test 2>&1"
pack_set --command "make install"
#pack_set --command "mv tmp.test $(pack_get --install-prefix)/"

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
    -M python$pV.cython.numpy.scipy.numexpr.scientific.matplotlib/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement scientificpython scipy cython numexpr) scientificpython scipy cython numexpr matplotlib)

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

create_module \
    -n "Nick Papior Andersen's DFT python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.numpy.scipy.scientific.ase.gpaw.inelastica/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement scientificpython scipy ase gpaw inelastica) scientificpython scipy ase gpaw inelastica)

create_module \
    -n "Nick Papior Andersen's parallel python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.kwant/$(get_c) \
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

