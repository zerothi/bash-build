for v in 5.1.2 ; do
add_package --package mumps \
	    http://mumps.enseeiht.fr/MUMPS_$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libmumps_common_omp.a
pack_set --lib -lzmumps -ldmumps -lcmumps -lsmumps -lmumps_common -lpord -lesmumps -lscotch -lscotcherr
pack_set --lib[omp] -lzmumps_omp -ldmumps_omp -lcmumps_omp -lsmumps_omp -lmumps_common_omp -lpord_omp -lesmumps -lscotch -lscotcherr
pack_set --lib[z] -lzmumps -lmumps_common -lpord -lesmumps -lscotch -lscotcherr
pack_set --lib[d] -ldmumps -lmumps_common -lpord -lesmumps -lscotch -lscotcherr
pack_set --lib[c] -lcmumps -lmumps_common -lpord -lesmumps -lscotch -lscotcherr
pack_set --lib[s] -lsmumps -lmumps_common -lpord -lesmumps -lscotch -lscotcherr

pack_set --lib[zomp] -lzmumps_omp -lmumps_common_omp -lpord_omp
pack_set --lib[domp] -ldmumps_omp -lmumps_common_omp -lpord_omp
pack_set --lib[comp] -lcmumps_omp -lmumps_common_omp -lpord_omp
pack_set --lib[somp] -lsmumps_omp -lmumps_common_omp -lpord_omp


if [[ $(vrs_cmp $v 5.0.0) -ge 0 ]]; then
    parmetisV=parmetis
else
    parmetisV=parmetis[3.2.0]
fi
pack_set --module-requirement $parmetisV

pack_cmd "echo '# Makefile for easy installation ' > Makefile.inc"

# We will create our own makefile from scratch (the included ones are ****)
if $(is_c intel) ; then
    
    # We need a patch for 5.0.X
    if [[ $(vrs_cmp $v 5.0) -eq 0 ]]; then
        o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-SIZE_OF
        dwn_file http://www.student.dtu.dk/~nicpa/packages/patch_MUMPS_sizeof $o
        pack_cmd "patch -p1 < $o"
    fi

    tmp_flag="-nofor-main"
    pack_cmd "sed -i '1 a\
SCALAP = $MKL_LIB -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -mkl=sequential \n\
LIBBLAS = $MKL_LIB -lmkl_blas95_lp64 -mkl=sequential \n' Makefile.inc"

else
    pack_set --module-requirement scalapack
    
    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    pack_cmd "sed -i '1 a\
SCALAP  = $(list --LD-rp scalapack) -lscalapack \n\
LIBBLAS = $(list --LD-rp +$la) $(pack_get -lib $la) \n' Makefile.inc"

fi

pack_set --module-requirement scotch

pack_cmd "sed -i '$ a\
LMETISDIR = $(pack_get --prefix $parmetisV) \n\
IMETIS = $(list --INCDIRS $parmetisV) \n\
LMETIS = $(list --LD-rp $parmetisV) -lparmetis -lmetis \n\
\n\
LPORDDIR = \$(topdir)/PORD/lib\n\
IPORD = -I\$(topdir)/PORD/include\n\
LPORD = -L\$(LPORDDIR) -Wl,-rpath=\$(LPORDDIR) -lpord \n\
\n\
SCOTCHDIR = $(pack_get --prefix scotch)\n\
LSCOTCHDIR = -L\$(SCOTCHDIR)/lib \n\
ISCOTCH = -I\$(SCOTCHDIR)/include \n\
LSCOTCH = \$(LSCOTCHDIR) -Wl,-rpath=\$(LSCOTCHDIR) -lesmumps -lscotch -lscotcherr\n\
#LSCOTCH = \$(LSCOTCHDIR) -Wl,-rpath=\$(LSCOTCHDIR) -lptesmumps -lptscotch -lptscotcherr -lscotch \n\
\n\
#ORDERINGSF = -Dpord -Dparmetis -Dptscotch \n\
ORDERINGSF = -Dpord -Dparmetis -Dscotch\n\
ORDERINGSC = \$(ORDERINGSF) \n\
\n\
LORDERINGS  = \$(LMETIS) \$(LPORD) \$(LSCOTCH) \n\
IORDERINGSF = \$(ISCOTCH) \n\
IORDERINGSC = \$(IMETIS) \$(IPORD) \$(ISCOTCH) \n\
\n\
\n\
PLAT = \n\
LIBEXT = .a \n\
OUTC = -o \n\
OUTF = -o \n\
RM = /bin/rm -f \n\
##CC = $CC \n\
##FC = $FC \n\
##FL = $FC \n\
CC = $MPICC \n\
FC = $MPIF90 \n\
FL = $MPIF90 \n\
AR = $AR vr \n\
RANLIB = ranlib \n\
\n\
LIBSEQ = -L\$(topdir)/libseq -lmpiseq \n\
INCSEQ = -I\$(topdir)/libseq \n\
\n\
LIBPAR = \$(SCALAP)\n\
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
##INCS = \$(INCSEQ) \n\
##LIBS = \$(LIBSEQ) \n\
INCS = \$(INCPAR) \n\
LIBS = \$(LIBPAR) \n\
##LIBSEQNEEDED = libseqneeded \n\
LIBSEQNEEDED = \n' Makefile.inc"

# Make commands
pack_cmd "make $(get_make_parallel) alllib"
pack_cmd "mkdir -p $(pack_get --prefix)/include"
pack_cmd "cp include/*.h $(pack_get --prefix)/include/"
pack_cmd "mkdir -p $(pack_get --LD)"
pack_cmd "cp lib/lib*.a $(pack_get --LD)/"

# Make clean and create threaded
pack_cmd "make clean"
if $(is_c intel) ; then
    pack_cmd "sed -i -e 's:mkl=sequential:mkl=parallel:g' Makefile.inc"

else

    if [[ "x$la" == "xopenblas" ]]; then
	pack_cmd "sed -i -e 's:$(pack_get -lib $la):$(pack_get -lib[omp] $la):g' Makefile.inc"
    fi
    
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

done

