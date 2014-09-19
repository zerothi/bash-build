add_package \
    --package mumps-serial \
    http://mumps.enseeiht.fr/MUMPS_4.10.0.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --library-path)/libmumps_common.a

pack_set --module-requirement metis
#pack_set --module-requirement scotch[5.1.12b]

pack_set --command "echo '# Makefile for easy installation ' > Makefile.inc"

# We will create our own makefile from scratch (the included ones are ****)
if $(is_c intel) ; then
    tmp_flag="-nofor-main"
    pack_set --command "sed -i '1 a\
LIBBLAS = $MKL_LIB -lmkl_blas95_lp64 -mkl=sequential \n' Makefile.inc"

else
    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --module-requirement atlas
	pack_set --command "sed -i '1 a\
LIBBLAS = $(list --LDFLAGS --Wlrpath atlas) -lf77blas -lcblas -latlas \n' Makefile.inc"
    elif [ $(pack_installed openblas) -eq 1 ] ; then
	pack_set --module-requirement openblas
	pack_set --command "sed -i '1 a\
LIBBLAS = $(list --LDFLAGS --Wlrpath openblas) -lopenblas \n' Makefile.inc"
    else
	pack_set --module-requirement blas
	pack_set --command "sed -i '1 a\
LIBBLAS = $(list --LDFLAGS --Wlrpath blas) -lblas \n' Makefile.inc"
    fi

fi

pack_set --command "sed -i '1 a\
LMETISDIR = $(pack_get --install-prefix metis[4.0.3]) \n\
IMETIS = $(list --INCDIRS metis[4.0.3]) \n\
LMETIS = $(list --LDFLAGS --Wlrpath metis[4.0.3]) -lmetis \n\
\n\
LPORDDIR = \$(topdir)/PORD/lib\n\
IPORD = -I\$(topdir)/PORD/include\n\
LPORD = -L\$(LPORDDIR) -Wl,-rpath=\$(LPORDDIR) -lpord \n\
\n\
#SCOTCHDIR = $(pack_get --install-prefix scotch)\n\
#LSCOTCHDIR = -L\$SCOTCHDIR)/lib \n\
#ISCOTCH = -I\$(SCOTCHDIR)/include \n\
#LSCOTCH = \$(LSCOTCHDIR) -Wl,-rpath=\$(LSCOTCHDIR) -lesmumps -lscotch -lscotcherr \n\
\n\
ORDERINGSF = -Dpord -Dmetis -Dscotch \n\
##ORDERINGSF = -Dpord -Dmetis -Dptscotch \n\
ORDERINGSF = -Dpord -Dmetis \n\
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
\n\
LIBOTHERS = \n\
\n\
#Preprocessor defs for calling Fortran from C (-DAdd_ or -DAdd__ or -DUPPER)\n\
CDEFS   = -DAdd_ \n\
#CDEFS   = -D \n\
\n\
#Begin Optimized options\n\
OPTF    = $FCFLAGS -O -DALLOW_NON_INIT $tmp_flag\n\
OPTL    = $FCFLAGS -O $tmp_flag\n\
OPTC    = $CFLAGS -O\n\
\n\
INCS = \$(INCSEQ) \n\
LIBS = \$(LIBSEQ) \n\
##INCS = \$(INCPAR) \n\
##LIBS = \$(LIBPAR) \n\
LIBSEQNEEDED = libseqneeded \n\
##LIBSEQNEEDED = \n' Makefile.inc"

# Make commands
pack_set --command "make $(get_make_parallel) alllib"
pack_set --command "mkdir -p $(pack_get --install-prefix)/include"
pack_set --command "cp include/*.h $(pack_get --install-prefix)/include/"
pack_set --command "mkdir -p $(pack_get --install-prefix)/lib"
pack_set --command "cp lib/lib*.a $(pack_get --library-path)/"
pack_set --command "cp libseq/lib*.a $(pack_get --library-path)/"

