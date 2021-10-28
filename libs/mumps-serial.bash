v=$(pack_get -version mumps)
add_package --package mumps-serial http://mumps.enseeiht.fr/MUMPS_$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libmumps_common_omp.a

pack_set --lib -lzmumps -ldmumps -lcmumps -lsmumps -lmumps_common -lpord -lmpiseq
pack_set --lib[omp] -lzmumps_omp -ldmumps_omp -lcmumps_omp -lsmumps_omp -lmumps_common_omp -lpord_omp -lmpiseq
pack_set --lib[z] -lzmumps -lmumps_common -lpord -lmpiseq
pack_set --lib[d] -ldmumps -lmumps_common -lpord -lmpiseq
pack_set --lib[c] -lcmumps -lmumps_common -lpord -lmpiseq
pack_set --lib[s] -lsmumps -lmumps_common -lpord -lmpiseq

pack_set --lib[zomp] -lzmumps_omp -lmumps_common_omp -lpord_omp -lmpiseq
pack_set --lib[domp] -ldmumps_omp -lmumps_common_omp -lpord_omp -lmpiseq
pack_set --lib[comp] -lcmumps_omp -lmumps_common_omp -lpord_omp -lmpiseq
pack_set --lib[somp] -lsmumps_omp -lmumps_common_omp -lpord_omp -lmpiseq

pack_set --module-requirement metis
# Using scotch requires a special interface :(

pack_cmd "echo '# Makefile for easy installation ' > Makefile.inc"

# We will create our own makefile from scratch (the included ones are ****)
if $(is_c intel) ; then
    tmp_flag="-nofor-main"
    pack_cmd "sed -i '1 a\
LIBBLAS = $MKL_LIB -lmkl_blas95_lp64 -mkl=sequential \n' Makefile.inc"

else

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    pack_cmd "sed -i '1 a\
LIBBLAS = $(list --LD-rp +$la) $(pack_get -lib $la) \n' Makefile.inc"

fi

pack_cmd "sed -i '1 a\
LMETISDIR = $(pack_get --prefix metis) \n\
IMETIS = $(list --INCDIRS metis) \n\
LMETIS = $(list --LD-rp metis) -lmetis \n\
\n\
LPORDDIR = \$(topdir)/PORD/lib\n\
IPORD = -I\$(topdir)/PORD/include\n\
LPORD = -L\$(LPORDDIR) -Wl,-rpath=\$(LPORDDIR) -lpord \n\
\n\
#SCOTCHDIR = $(pack_get --prefix scotch)\n\
#LSCOTCHDIR = -L\$SCOTCHDIR)/lib \n\
#ISCOTCH = -I\$(SCOTCHDIR)/include \n\
#LSCOTCH = \$(LSCOTCHDIR) -Wl,-rpath=\$(LSCOTCHDIR) -lscotch \n\
\n\
ORDERINGSF = -Dpord -Dmetis #-Dscotch \n\
##ORDERINGSF = -Dpord -Dmetis # -Dptscotch \n\
ORDERINGSC = \$(ORDERINGSF) \n\
\n\
LORDERINGS  = \$(LMETIS) \$(LPORD) \$(LSCOTCH) \n\
IORDERINGSF = \$(ISCOTCH) \n\
IORDERINGSC = \$(IMETIS) \$(IPORD) \$(ISCOTCH) \n\
LORDERINGS  = \$(LMETIS) \$(LPORD) \n\
IORDERINGSF = \n\
IORDERINGSC = \$(IMETIS) \$(IPORD) \n\
\n\
\n\
PLAT = \n\
LIBEXT = .a \n\
OUTC = -o \n\
OUTF = -o \n\
RM = /bin/rm -f \n\
CC = $CC \n\
FC = $FC \n\
FL = $FC \n\
AR = $AR vr \n\
RANLIB = ranlib \n\
\n\
LIBSEQ = -L\$(topdir)/libseq -lmpiseq \n\
INCSEQ = -I\$(topdir)/libseq \n\
\n\
LIBOTHERS = \n\
\n\
#Preprocessor defs for calling Fortran from C (-DAdd_ or -DAdd__ or -DUPPER)\n\
CDEFS   = -DAdd_ \n\
#CDEFS   = -D \n\
\n\
#Begin Optimized options\n\
OPTF    = $FCFLAGS -O -DALLOW_NON_INIT $tmp_flag \n\
OPTL    = $FCFLAGS -O $tmp_flag \n\
OPTC    = $CFLAGS -O -DWITHOUT_PTHREAD \n\
\n\
INCS = \$(INCSEQ) \n\
LIBS = \$(LIBSEQ) \n\
LIBSEQNEEDED = libseqneeded \n' Makefile.inc"

# Make commands
pack_cmd "make $(get_make_parallel) alllib"
pack_cmd "mkdir -p $(pack_get --prefix)/include"
pack_cmd "cp include/*.h $(pack_get --prefix)/include/"
pack_cmd "mkdir -p $(pack_get --LD)"
pack_cmd "cp lib/lib*.a $(pack_get --LD)/"
pack_cmd "cp libseq/lib*.a $(pack_get --LD)/"

# Make clean and create threaded
pack_cmd "make clean"
if $(is_c intel) ; then
    pack_cmd "sed -i -e 's:mkl=sequential:mkl=parallel:g' Makefile.inc"

else

    case $la in
	*)
	    pack_cmd "sed -i -e 's:$(pack_get -lib $la):$(pack_get -lib[omp] $la):g' Makefile.inc"
	    ;;
    esac
    
fi

pack_cmd "sed -i '$ a\
CDEFS += -DMUMPS_OPENMP\n\
OPTF += $FLAG_OMP -DBLR_MT\n\
OPTL += $FLAG_OMP\n\
OPTC += $FLAG_OMP\n' Makefile.inc"

# Make commands
pack_cmd "make $(get_make_parallel) alllib"
pack_cmd "cp include/*.h $(pack_get --prefix)/include/"
pack_cmd "cd lib"
pack_cmd "for l in lib*.a ; do cp \$l $(pack_get --LD)/\${l//.a/_omp.a} ; done"

