# Install Python 3 versions
v=3.3.3
if $(is_host n-) ; then
    add_package --package Python http://www.python.org/ftp/python/$v/Python-$v.tgz
else
    add_package --package python http://www.python.org/ftp/python/$v/Python-$v.tgz
fi

# The settings
pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --module-requirement zlib

pack_set --install-query $(pack_get --install-prefix)/bin/python3

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "LDFLAGS='$(list --LDFLAGS --Wlrpath zlib)'" \
    --command-flag "CPPFLAGS='$(list --INCDIRS zlib)'" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

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
set_parent_exec python3
# Install all python packages
source python-install.bash
clear_parent

# Initialize the module read path
old_path=$(build_get --module-path)
build_set --module-path $old_path-npa

create_module \
    -n "Nick Papior Andersen's basic python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.cython.numpy.scipy.numexpr.matplotlib/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement scipy cython numexpr) scipy cython numexpr matplotlib)

create_module \
    -n "Nick Papior Andersen's parallel python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.cython.mpi4py.numpy.scipy/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement scipy mpi4py) scipy cython mpi4py)

build_set --module-path $old_path

exit 0