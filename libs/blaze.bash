add_package https://bitbucket.org/blaze-lib/blaze/downloads/blaze-3.2.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/include/blaze

file=NPA.config

pack_cmd "echo '# Config for NPA' > $file"

pack_cmd "sed -i '1 a\
VERSION=\"release\"\n\
CXX=\"$CXX\"\n\
CXXFLAGS=\"$CXXFLAGS\"\n\
LIBRARY=\"both\"\n\
MPI=\"no\"\n\
' $file"

if [[ $(pack_installed boost) -eq 1 ]]; then
    pack_set --mod-req boost
    
    pack_cmd "sed -i '1 a\
BOOST_INCLUDE_PATH=\"$(pack_get --prefix)/include\"\n\
BOOST_LIBRARY_PATH=\"$(pack_get --LD)\"\n\
BOOST_SYSTEM_LIBRARY=\"boost_system $(list -LD-rp boost)\"\n\
BOOST_THREAD_LIBRARY=\"boost_thread $(list -LD-rp boost)\"\n\
' $file"
    
fi

pack_cmd "./configure $file"

# Create installation directory
pack_cmd "mkdir -p $(pack_get --LD)"
pack_cmd "mkdir -p $(pack_get --prefix)/include"

pack_cmd "cp -r ./blaze $(pack_get --prefix)/include"

if [[ $(pack_installed boost) -eq 1 ]]; then
    pack_cmd "make"
    pack_cmd "cp ./lib/* $(pack_get --LD)/"
fi




