add_package --package arpack \
    --directory ARPACK \
    http://www.caam.rice.edu/software/ARPACK/SRC/arpack96.tar.gz

pack_set -s $IS_MODULE

# Required as the version has just been set
pack_set --install-query $(pack_get --install-prefix)/lib/libarpack.a

# Apply patch
pack_set --command "pushd ../"
pack_set --command "wget http://www.caam.rice.edu/software/ARPACK/SRC/patch.tar.gz"
pack_set --command "tar xfz patch.tar.gz"
pack_set --command "popd"


file=ARmake.inc
pack_set --command "echo '# New makefile' > $file"
pack_set --command "echo home = \$(pwd) >> $file"

pack_set --command "sed -i '1 a\
FC = $FC\n\
FFLAGS = $FCFLAGS\n\
CD = cd\n\
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
DIRS   = \$(UTILdir) \$(SRCdir)\n\
ARPACKLIB = \$(home)/libarpack.a\n\
ALIBS = \$(LAPACKLIB) \$(BLASLIB)\n\
.SUFFIXES:\n\
.SUFFIXES: .f .o\n\
.DEFAULT:\n\
\t@\$(ECHO) Unknown target \$@, try: make help\n\
.f.o:\n\
\t@\$(ECHO) Making \$@ from \$<\n\
\t@\$(FC) -c \$(FFLAGS) \$<\n\
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
LAPACKLIB = -llapack_atlas\n\
BLASLIB  = -lf77blas -lcblas -latlas\n\
LDFLAGS = $(list --LDFLAGS --Wlrpath atlas)\n\
' $file"
    else
	pack_set --module-requirement blas
	pack_set --module-requirement lapack
	pack_set --command "sed -i '1 a\
LAPACKLIB = llapack\n\
BLASLIB  = -lblas\n\
LDFLAGS = $(list --LDFLAGS --Wlrpath blas lapack)\n\
' $file"

    fi

    # We need to correct for etime which has enterred as
    # an intrinsic rather than external function
    pack_set --command "sed -i -e 's:.*EXTERNAL[ ]*ETIME.*::g' UTIL/second.f"

fi

pack_set --command "make"

pack_set --command "mkdir -p $(pack_get --install-prefix)/lib"
pack_set --command "cp libarpack.a $(pack_get --install-prefix)/lib/"
