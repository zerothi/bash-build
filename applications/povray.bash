add_package \
    --build generic \
    http://www.povray.org/ftp/pub/povray/Old-Versions/Official-3.62/Unix/povray-3.6.1.tar.bz2

pack_set -s $IS_MODULE

# Force the named alias
pack_set --install-query $(pack_get --prefix)/bin/povray

pack_set --module-opt "--lua-family povray"

# Compile commands
pack_set --command "./configure" \
	--command-flag "COMPILED_BY='Nick Papior Andersen <nickpapior@gmail.com>'" \
	--command-flag "--prefix=$(pack_get --prefix)"

# Make commands
pack_set --command "make"
pack_set --command "make install"

## install commands... (this will install the non-GUI version)
#pack_set --command "printf '%s%s\n' 'U' '$(pack_get --prefix)' | ./install -no-arch-check"

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias)
