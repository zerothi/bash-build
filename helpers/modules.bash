add_package --build generic-no-version http://downloads.sourceforge.net/project/modules/Modules/modules-3.2.10/modules-3.2.10.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/Modules

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

# Make link to default version (always the newest version, latest installation)
pack_set --command "cd $(pack_get --prefix)/Modules/"
pack_set --command "ln -fs $(pack_get --version) default" 