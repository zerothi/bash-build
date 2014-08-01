add_package --package parpack \
    --directory ARPACK \
    http://www.caam.rice.edu/software/ARPACK/SRC/arpack96.tar.gz

pack_set -s $IS_MODULE

# Required as the version has just been set
pack_set --install-query $(pack_get --install-prefix)/lib/libparpack.a

pack_set --module-requirement openmpi

# Apply patch
pack_set --command "pushd ../"
pack_set --command "wget http://www.caam.rice.edu/software/ARPACK/SRC/patch.tar.gz"
pack_set --command "tar xfz patch.tar.gz"
pack_set --command "rm patch.tar.gz"

# Apply parallel source and patch
pack_set --command "wget http://www.caam.rice.edu/software/ARPACK/SRC/parpack96.tar.gz"
pack_set --command "tar xfz parpack96.tar.gz"
pack_set --command "rm parpack96.tar.gz"
pack_set --command "wget http://www.caam.rice.edu/software/ARPACK/SRC/ppatch.tar.gz"
pack_set --command "tar xfz ppatch.tar.gz"
pack_set --command "rm ppatch.tar.gz"

pack_set --command "popd"

file=ARmake.inc
pack_set --command "echo '# New makefile' > $file"
pack_set --command "echo home = \$(pwd) >> $file"

pack_set --command "sed -i '1 a\
PFC = $MPIFC\n\
PFFLAGS = $FCFLAGS\n\
FC = $FC\n\
FFLAGS = $FCFLAGS\n\
CPP = $CPP \n\
CHMOD = chmod\n\
CHFLAGS = -f \n\
COMPRESS = compress\n\
CD = cd\n\
CP = cp\n\
MKDIR = mkdir\n\
MDFLAGS = -p\n\
TAR = tar\n\
ECHO = echo\n\
LN = ln \n\
LNFLAGS = -s\n\
MAKE = make\n\
RM = rm\n\
RMFLAGS = -f\n\
SHELL = /bin/sh\n\
AR=$AR\n\
ARFLAGS = rv\n\
RANLIB = ranlib\n\
UTILdir = \$(home)/UTIL\n\
SRCdir = \$(home)/SRC\n\
COMM   = MPI\n\
PSRCdir = \$(home)/PARPACK/SRC/\$(COMM)\n\
PUTILdir = \$(home)/PARPACK/UTIL/\$(COMM)\n\
DIRS   = \$(UTILdir) \$(SRCdir)\n\
ARPACKLIB = \$(home)/libarpack.a\n\
PARPACKLIB = \$(home)/libparpack.a\n\
ALIBS = \$(LAPACKLIB) \$(BLASLIB)\n\
MPILIBS = \n\
PLIBS = \$(PARPACKLIB) \$(ALIBS) \$(MPILIBS)\n\
.SUFFIXES:\n\
.SUFFIXES: .F .f .o\n\
.DEFAULT:\n\
\t@\$(ECHO) Unknown target \$@, try: make help\n\
.f.o:\n\
\t@\$(ECHO) Making \$@ from \$<\n\
\t@\$(FC) -c \$(FFLAGS) \$<\n\
.F.f:\n\
\t@\$(ECHO) Making \$*.f from \$<\n\
\t@\$(CPP) -P -DSINGLE \$(CPPFLAGS) \$< \$*.f\n\
\t@\$(ECHO) Making d\$*.f from \$<\n\
\t@\$(CPP) -P -DDOUBLE \$(CPPFLAGS) \$< d\$*.f\n\
' $file"

if $(is_c intel) ; then
    pack_set --command "sed -i '1 a\
LAPACKLIB = -mkl=sequential\n\
BLASLIB  = -mkl=sequential\n\
LDFLAGS = \n\
' $file"

else

    if [ $(pack_installed atlas) -eq 1 ]; then
	pack_set --module-requirement atlas
	pack_set --command "sed -i '1 a\
LAPACKLIB = -llapack\n\
BLASLIB  = -lf77blas -lcblas -latlas\n\
LDFLAGS = $(list --LDFLAGS --Wlrpath atlas)\n\
' $file"
    elif [ $(pack_installed openblas) -eq 1 ]; then
	pack_set --module-requirement openblas
	pack_set --command "sed -i '1 a\
LAPACKLIB = -llapack\n\
BLASLIB  = -lopenblas\n\
LDFLAGS = $(list --LDFLAGS --Wlrpath openblas)\n\
' $file"
    else
	pack_set --module-requirement blas
	pack_set --command "sed -i '1 a\
LAPACKLIB = llapack\n\
BLASLIB  = -lblas\n\
LDFLAGS = $(list --LDFLAGS --Wlrpath blas)\n\
' $file"

    fi

    # We need to correct for etime which has enterred as
    # an intrinsic rather than external function
    pack_set --command "sed -i -e 's:.*EXTERNAL[ ]*ETIME.*::g' UTIL/second.f"

fi

pack_set --command "make lib"
pack_set --command "sed -i -e 's/^FC.*//;s/^FFLAGS.*//;s/^PFC/FC/;s/^PFFLAGS/FFLAGS/' $file"
pack_set --command "make plib"

pack_set --command "mkdir -p $(pack_get --install-prefix)/lib"
pack_set --command "cp libarpack.a libparpack.a $(pack_get --install-prefix)/lib/"
