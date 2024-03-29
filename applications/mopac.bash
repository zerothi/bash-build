# apt-get libpng libjpeg-dev libtiff5-dev libpng12-dev
add_package -build generic -version 2016 -directory . \
        -package mopac \
	    http://openmopac.net/MOPAC2016_for_Linux_64_bit.zip

pack_set -s $IS_MODULE

pack_set -install-query $(pack_get -prefix)/bin/mopac

p=$(pack_get -prefix)
pack_set -module-opt "-prepend-ENV LD_LIBRARY_PATH=$p/lib"
pack_set -module-opt "-set-ENV MOPAC_LICENSE=$p/bin"
#pack_set -module-opt "-echo \'\"Please read the Academic MOPAC license, it is your responsibility to uphold it.\"\'"

pack_cmd "rm Example\ data\ set.mop Installation\ instructions.txt mopac.csh"

pack_cmd "mkdir -p $p/bin"
pack_cmd "mkdir -p $p/lib"
pack_cmd "mv libiomp5.so $p/lib"
pack_cmd "mv MOPAC2016.exe $p/bin"
pack_cmd "pushd $p/bin"

pack_cmd "chmod a+x MOPAC2016.exe"
pack_cmd "ln -s MOPAC2016.exe mopac"

# Fix license stuff
pack_cmd "echo '' > .tmp_exec"
pack_cmd "echo 'yes' >> .tmp_exec"
pack_cmd "MOPAC_LICENSE=$p/bin LD_LIBRARY_PATH=$p/lib ./mopac 7357613a66970542 < .tmp_exec"
pack_cmd "rm .tmp_exec"


pack_cmd "popd"
