add_package --package parpack \
	    --directory ARPACK \
	    http://www.caam.rice.edu/software/ARPACK/SRC/arpack96.tar.gz

pack_set -s $IS_MODULE

# Required as the version has just been set
pack_set --install-query $(pack_get --LD)/libparpack.a

pack_set --module-requirement mpi

oA=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-patch.tar.gz
dwn_file http://www.caam.rice.edu/software/ARPACK/SRC/patch.tar.gz $oA
oP=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-parpack96.tar.gz
dwn_file http://www.caam.rice.edu/software/ARPACK/SRC/parpack96.tar.gz $oP
oPP=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-ppatch.tar.gz
dwn_file http://www.caam.rice.edu/software/ARPACK/SRC/ppatch.tar.gz $oPP

# Apply patch
pack_cmd "pushd ../"
pack_cmd "tar xfz $oA"

# Apply parallel source and patch
pack_cmd "tar xfz $oP"
pack_cmd "tar xfz $oPP"

pack_cmd "popd"

file=ARmake.inc
pack_cmd "echo '# New makefile' > $file"
pack_cmd "echo home = \$(pwd) >> $file"

pack_cmd "sed -i '1 a\
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
    pack_cmd "sed -i '1 a\
LAPACKLIB = -mkl=sequential\n\
BLASLIB  = -mkl=sequential\n\
LDFLAGS = \n\
' $file"

else

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la

    pack_cmd "sed -i '1 a\
LAPACKLIB = $(pack_get -lib $la)\n\
BLASLIB   = \$(LAPACKLIB) \n\
LDFLAGS   = $(list --LD-rp +$la)\n\
' $file"

    # We need to correct for etime which has enterred as
    # an intrinsic rather than external function
    pack_cmd "sed -i -e 's:.*EXTERNAL[ ]*ETIME.*::g' UTIL/second.f"

fi

pack_cmd "make lib"
pack_cmd "sed -i -e 's/^FC.*//;s/^FFLAGS.*//;s/^PFC/FC/;s/^PFFLAGS/FFLAGS/' $file"
pack_cmd "make plib"

pack_cmd "mkdir -p $(pack_get --LD)"
pack_cmd "cp libarpack.a libparpack.a $(pack_get --LD)/"
