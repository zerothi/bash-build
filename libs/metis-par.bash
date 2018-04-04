add_package http://glaros.dtc.umn.edu/gkhome/fetch/sw/parmetis/parmetis-4.0.3.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libparmetis.a

pack_set --module-requirement mpi

# Make commands 
pack_cmd "sed -i -e 's/^\(cputype\).*/\1 = unknown/' Makefile"
pack_cmd "sed -i -e 's/^\(systype\).*/\1 = linux/' Makefile"
pack_cmd "sed -i -e 's/^\(cputype\).*/\1 = unknown/' metis/Makefile"
pack_cmd "sed -i -e 's/^\(systype\).*/\1 = linux/' metis/Makefile"
pack_cmd "sed -i -e 's/^\(cc\).*/\1 = $CC/' metis/Makefile"

# Defaults to 32 bits information within METIS...
pack_cmd "sed -i -e 's/\(define IDXTYPEWIDTH\).*/\1 32/' metis/include/metis.h"
pack_cmd "sed -i -e 's/\(define REALTYPEWIDTH\).*/\1 32/' metis/include/metis.h"
pack_cmd "cd metis"
pack_cmd "make config prefix=$(pack_get --prefix)"
pack_cmd "cd build/linux-unknown"
pack_cmd "make"
pack_cmd "make install"
pack_cmd "cd ../../../"
pack_cmd "make config prefix=$(pack_get --prefix)"
pack_cmd "cd build/linux-unknown"
pack_cmd "make"
pack_cmd "make install"
