# apt-get libpng libjpeg-dev libtiff5-dev libpng12-dev
add_package -build generic -version 2016 -directory . \
	    http://openmopac.net/MOPAC2016_for_Linux_64_bit.zip

pack_set -s $IS_MODULE

pack_set -install-query $(pack_get -prefix)/bin/openmopac

p=$(pack_get -prefix)
pack_set -module-opt "-prepend-ENV LD_LIBRARY_PATH=$p/lib"

pack_cmd "mkdir -p $p/bin"
pack_cmd "mkdir -p $p/lib"
pack_cmd "mv libiomp5.so $p/lib"
pack_cmd "mv MOPAC2016.exe $p/bin"
pack_cmd "cd $p/bin"

pack_cmd "chmod a+x MOPAC2016.exe"
pack_cmd "ln -s mopac MOPAC2016.exe"

# Fix license stuff
pack_cmd "./mopac 7357613a66970542"

