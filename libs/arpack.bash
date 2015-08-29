add_package --package arpack \
	    --directory ARPACK \
	    http://www.caam.rice.edu/software/ARPACK/SRC/arpack96.tar.gz

pack_set -s $IS_MODULE

# Required as the version has just been set
pack_set --install-query $(pack_get --LD)/libarpack.a

# First download file
o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-patch.tar.gz
dwn_file http://www.caam.rice.edu/software/ARPACK/SRC/patch.tar.gz $o

# Apply patch
pack_cmd "pushd ../"
pack_cmd "tar xfz $o"
pack_cmd "popd"

file=ARmake.inc
pack_cmd "echo '# New makefile' > $file"
pack_cmd "echo home = \$(pwd) >> $file"

pack_cmd "sed -i '1 a\
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
    pack_cmd "sed -i '1 a\
LAPACKLIB = -mkl=sequential\n\
BLASLIB  = -mkl=sequential\n\
LDFLAGS = \n\
' $file"

else

    for la in $(choice linalg) ; do
	if [[ $(pack_installed $la) -eq 1 ]]; then
	    pack_set --module-requirement $la
	    tmp=
	    [[ "x$la" == "xatlas" ]] && \
		tmp="$tmp -lf77blas -lcblas"
	    tmp="$tmp -l$la"
	    pack_cmd "sed -i '1 a\
LAPACKLIB = -llapack\n\
BLASLIB   = $tmp\n\
LDFLAGS = $(list --LD-rp $la)\n\
' $file"
	    break
	fi
    done

    # We need to correct for etime which has enterred as
    # an intrinsic rather than external function
    pack_cmd "sed -i -e 's:.*EXTERNAL[ ]*ETIME.*::g' UTIL/second.f"

fi

pack_cmd "make"

pack_cmd "mkdir -p $(pack_get --LD)"
pack_cmd "cp libarpack.a $(pack_get --LD)/"
