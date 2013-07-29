# Gdis needs libgtkglext1-dev for installation
# libgtk2.0-dev

for v in 0.91b ; do 
add_package --version $v \
    http://www.student.dtu.dk/~nicpa/packages/gdis-$v.tar.gz

pack_set -s $IS_MODULE

pack_set $(list --prefix "--host-reject " thul surt slid etse a0 b0 c0 d0 n0 p0 q0 g0 n-)

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)

# Force the named alias
pack_set --install-query $(pack_get --install-prefix)/bin/gdis

# Install commands that it should run
pack_set --command "mkdir -p $(pack_get --install-prefix)/bin"
# install commands... (this will install the non-GUI version)
pack_set --command "echo -e '1\n$(pack_get --install-prefix)/bin' | ./install"
# Apparently it is not made executable ???
pack_set --command "chmod a+x $(pack_get --install-prefix)/bin/gdis"

pack_install

create_module \
    --module-path $(get_installation_path)/modules-npa-apps \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(get_default_modules) $(pack_get --module-requirement)) \
    -L $(pack_get --alias)

done
