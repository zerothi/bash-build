add_package http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libmetis.a

pack_set --lib -lmetis

# Make commands
pack_cmd "sed -i -e 's/^cputype.*/cputype = unknown/' Makefile"
pack_cmd "sed -i -e 's/^systype.*/systype = linux/' Makefile"
pack_cmd "sed -i -e 's/^cc.*/cc = $CC/' Makefile"
# Defaults to 32 bits information within METIS...
pack_cmd "sed -i -e 's/\(define IDXTYPEWIDTH\).*/\1 32/' include/metis.h"
pack_cmd "sed -i -e 's/\(define REALTYPEWIDTH\).*/\1 32/' include/metis.h"

pack_cmd "module load build-tools"

pack_cmd "make config prefix=$(pack_get --prefix)"
pack_cmd "cd build/linux-unknown"
pack_cmd "make"
pack_cmd "make install"

pack_cmd "module unload build-tools"
