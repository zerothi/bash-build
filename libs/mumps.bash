add_package --package mumps \
    http://mumps.enseeiht.fr/MUMPS_4.10.0.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libmumps_common.a

parmetisV=3.2.0
pack_set --module-requirement parmetis[$parmetisV]
pack_set --module-requirement scotch

pack_set --command "echo '# Makefile for easy installation ' > Makefile.inc"

# We will create our own makefile from scratch (the included ones are ****)
if $(is_c intel) ; then
    tmp_flag="-nofor-main"
    pack_set --command "sed -i '1 a\
SCALAP = $MKL_LIB -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -mkl=sequential \n\
LIBBLAS = $MKL_LIB -lmkl_blas95_lp64 -mkl=sequential \n' Makefile.inc"

else

    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ]; then
	    pack_set --module-requirement $la
	    tmp=
	    [ "x$la" == "xatlas" ] && \
		tmp="-lf77blas -lcblas"
	    tmp="$tmp -l$la"
	    pack_set --command "sed -i '1 a\
SCALAP  = $(list --LDFLAGS --Wlrpath $la) -lscalapack \n\
LIBBLAS = $(list --LDFLAGS --Wlrpath $la) $tmp \n' Makefile.inc"
	    break
	fi
    done

fi

pack_set --command "sed -i '1 a\
LMETISDIR = $(pack_get --prefix parmetis[$parmetisV]) \n\
IMETIS = $(list --INCDIRS parmetis[$parmetisV]) \n\
LMETIS = $(list --LDFLAGS --Wlrpath parmetis[$parmetisV]) -lparmetis -lmetis \n\
\n\
LPORDDIR = \$(topdir)/PORD/lib\n\
IPORD = -I\$(topdir)/PORD/include\n\
LPORD = -L\$(LPORDDIR) -Wl,-rpath=\$(LPORDDIR) -lpord \n\
\n\
#SCOTCHDIR = $(pack_get --prefix scotch)\n\
#LSCOTCHDIR = -L\$SCOTCHDIR)/lib \n\
#ISCOTCH = -I\$(SCOTCHDIR)/include \n\
##LSCOTCH = \$(LSCOTCHDIR) -Wl,-rpath=\$(LSCOTCHDIR) -lesmumps -lscotch -lscotcherr \n\
#LSCOTCH = \$(LSCOTCHDIR) -Wl,-rpath=\$(LSCOTCHDIR) -lptesmumps -lptscotch -lptscotcherr \n\
\n\
##ORDERINGSF = -Dpord -Dmetis -Dscotch \n\
#ORDERINGSF = -Dpord -Dparmetis -Dptscotch \n\
ORDERINGSF = -Dpord -Dparmetis \n\
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
OPTF    = $FCFLAGS -O -DALLOW_NON_INIT $tmp_flag\n\
OPTL    = $FCFLAGS -O $tmp_flag\n\
OPTC    = $CFLAGS -O\n\
\n\
##INCS = \$(INCSEQ) \n\
##LIBS = \$(LIBSEQ) \n\
INCS = \$(INCPAR) \n\
LIBS = \$(LIBPAR) \n\
##LIBSEQNEEDED = libseqneeded \n\
LIBSEQNEEDED = \n' Makefile.inc"

# Make commands
pack_set --command "make $(get_make_parallel) alllib"
pack_set --command "mkdir -p $(pack_get --prefix)/include"
pack_set --command "cp include/*.h $(pack_get --prefix)/include/"
pack_set --command "mkdir -p $(pack_get --LD)"
pack_set --command "cp lib/lib*.a $(pack_get --LD)/"

