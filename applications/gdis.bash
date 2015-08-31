# Gdis needs 
# apt-get install libgtkglext1-dev libgtk2.0-dev

for v in 0.99 ; do 
add_package --build generic \
    http://www.student.dtu.dk/~nicpa/packages/gdis-$v.tar.gz

pack_set -s $IS_MODULE -s $CRT_DEF_MODULE

pack_set --module-opt "--lua-family gdis"

# Force the named alias
pack_set --install-query $(pack_get --prefix)/bin/gdis

# Install commands that it should run
pack_cmd "mkdir -p $(pack_get --prefix)/bin"
# install commands... (this will install the non-GUI version)
pack_cmd "printf '%s\n%s\n' '1' '$(pack_get --prefix)/bin' | ./install"
# Apparently it is not made executable ???
pack_cmd "chmod a+x $(pack_get --prefix)/bin/gdis"

done
