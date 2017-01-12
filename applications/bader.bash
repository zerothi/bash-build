add_package --version 1.0 \
    http://theory.cm.utexas.edu/henkelman/code/bader/download/bader.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/bin/bader

file=Makefile
pack_cmd "cp makefile.lnx_ifort $file"
pack_cmd "sed -i -e 's/\(FC[[:space:]]*=\).*/\1 $FC/' $file"
pack_cmd "sed -i -e 's/\(FFLAGS[[:space:]]*=\).*/\1 $FFLAGS/' $file"
pack_cmd "sed -i -e 's/\(LINK[[:space:]]*=\).*/\1 /' $file"

# Make commands
pack_cmd "make bader"
pack_cmd "mkdir -p $(pack_get --prefix)/bin/"
pack_cmd "cp bader $(pack_get --prefix)/bin/"

