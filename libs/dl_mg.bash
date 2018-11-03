add_package --package dlmg \
	    https://ccpforge.cse.rl.ac.uk/gf/download/frsrelease/609/8974/dl_mg_2.0.2.tar

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libdlmg.a

pack_set -lib -ldlmg
pack_set -lib[omp] -ldlmg_omp

pack_set --module-requirement mpi

file=platforms/nicpa.inc
libdir=$(pack_get --prefix)/lib
pack_cmd "echo '# Makefile for easy installation ' > $file"

pack_cmd "sed -i '$ a\
OBJDIR = obj\n\
LIBDIR = $libdir\n\
FC = $MPIFC \n\
USE_OPENMP = yes \n\
MPIFLAGS = -DMPI \n\
FFLAGS = $FCFLAGS $FLAG_OMP\n' $file"

pack_cmd "make PLATFORM=nicpa $libdir/libdlmg.a"
pack_cmd "cp $libdir/libdlmg.a $libdir/libdlmg_omp.a"
pack_cmd "rm -rf obj *.mod"
pack_cmd "sed -i 's:$FLAG_OMP::g;s:USE_OPENMP.*:USE_OPENMP = no:g' $file"
pack_cmd "make PLATFORM=nicpa $libdir/libdlmg.a"

# Ensure we have modules in include directory
pack_cmd "mkdir -p $(pack_get --prefix)/include"
pack_cmd "for f in dl_mg.mod obj/dl_mg.mod obj/*.inc ; do [ -e \$f ] && cp \$f $(pack_get --prefix)/include/\$(basename \$f) ; done"
