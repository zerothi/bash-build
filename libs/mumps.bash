add_package http://mumps.enseeiht.fr/MUMPS_4.10.0.tar.gz

pack_set --alias mumps

pack_set -s $IS_MODULE

# Required as the version has just been set
pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/libmumps_common.a

pack_set --module-requirement parmetis[3.2.0]

if $(is_c gnu) ; then
    pack_set --module-requirement atlas
    pack_set --module-requirement scalapack
fi

pack_set --command "echo '# Makefile for easy installation ' > Makefile.inc"

# We will create our own makefile from scratch (the included ones are ****)
if $(is_c gnu) ; then
    pack_set --command "sed -i '1 a\
SCALAP = $(list --LDFLAGS --Wlrpath scalapack) -lscalapack \n\
LIBBLAS = $(list --LDFLAGS --Wlrpath atlas) -lf77blas -lcblas -latlas \n' Makefile.inc"
elif $(is_c intel) ; then
    pack_set --command "sed -i '1 a\
SCALAP = $MKL_LIB -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -mkl=sequential \n\
LIBBLAS = $MKL_LIB -lmkl_blas95_lp64 -mkl=sequential \n' Makefile.inc"
fi

pack_set --command "sed -i '1 a\
LMETISDIR = $(pack_get --install-prefix parmetis) \n\
IMETIS = $(list --INCDIRS parmetis) \n\
LMETIS = $(list --LDFLAGS --Wlrpath parmetis) -lparmetis -lmetis \n\
\n\
LPORDDIR = \$(topdir)/PORD/lib\n\
IPORD = -I\$(topdir)/PORD/include\n\
LPORD = -L\$(LPORDDIR) -Wl,-rpath=\$(LPORDDIR) -lpord \n\
\n\
ORDERINGSF = -Dpord -Dmetis -Dparmetis \n\
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
CC = $MPICC \n\
FC = $MPIF90 \n\
FL = $MPIF90 \n\
AR = $AR vr \n\
RANLIB = ranlib \n\
\n\
LIBSEQ = -L\$(topdir)/libseq -Wl,-rpath=\$(topdir)/libseq -lmpiseq \n\
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
OPTF    = -O -DALLOW_NON_INIT -nofor-main\n\
OPTL    = -O -nofor-main\n\
OPTC    = -O\n\
\n\
INCS = \$(INCPAR) \n\
LIBS = \$(LIBPAR) \n\
LIBSEQNEEDED = \n' Makefile.inc"

# Make commands
pack_set --command "make $(get_make_parallel) alllib"
pack_set --command "mkdir -p $(pack_get --install-prefix)/include"
pack_set --command "cp include/*.h $(pack_get --install-prefix)/include/"
pack_set --command "mkdir -p $(pack_get --install-prefix)/lib"
pack_set --command "cp lib/lib*.a $(pack_get --install-prefix)/lib/"
