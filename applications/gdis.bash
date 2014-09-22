# Gdis needs 
# apt-get install libgtkglext1-dev libgtk2.0-dev

for v in 0.99 ; do 
add_package --build generic \
    http://www.student.dtu.dk/~nicpa/packages/gdis-$v.tar.gz

pack_set -s $IS_MODULE

pack_set $(list --prefix "--host-reject " surt muspel slid n- hemera eris)

pack_set --module-opt "--lua-family gdis"

# Force the named alias
pack_set --install-query $(pack_get --prefix)/bin/gdis

# Install commands that it should run
pack_set --command "mkdir -p $(pack_get --prefix)/bin"
# install commands... (this will install the non-GUI version)
pack_set --command "printf '%s\n%s\n' '1' '$(pack_get --prefix)/bin' | ./install"
# Apparently it is not made executable ???
pack_set --command "chmod a+x $(pack_get --prefix)/bin/gdis"

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --mod-req)) \
    -L $(pack_get --alias)

done
