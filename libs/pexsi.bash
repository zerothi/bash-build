add_package https://math.berkeley.edu/~linlin/pexsi/download/download.php?file=pexsi_v0.9.0.tar.gz

pack_set -s $IS_MODULE
pack_set --install-query $(pack_get --LD)/libscalapack.a

pack_set $(list -p '--mod-req ' mpi superlu-dist parmetis scotch)


# Prepare the make file
tmp="sed -i -e"
file=make.inc
pack_cmd "echo '# NRP compilation of PEXSI' > $file"
pack_cmd "sed -i '1 a\
PEXSI_DIR = $(pwd) \n\
COMPILE_MODE = release\n\
USE_PROFILE = 0 \n\
PAR_ND_LIBRARY = ptscotch \n\
SEQ_ND_LIBRARY = scotch \n\
SUFFIX = linux \n\
CC = $MPICC \n\
CXX = $MPICXX \n\
FC = $MPIFC \n\
LOADER = \$(CXX) \n\
AR = $AR \n\
ARFLAGS = rvcu \n\
RANLIB = ranlib \n\
CP = cp \n\
RM = rm \n\
RMFLAGS = -f \n\
##\n\
CFLAGS = $CFLAGS \n\
FFLAGS = $FFLAGS \n\
CXXFLAGS = $CXXFLAGS \n\
CCDEFS = -DRELEASE -DDEBUG=0 -DAdd_##\n\
DSUPERLU_DIR = $(pack_get --prefix superlu-dist)\n\
METIS_DIR = $(pack_get --prefix parmetis)\n\
SCOTCH_DIR = $(pack_get --prefix scotch)\n\
##\n\
##\n\
INCLUDES = -I\$(DSUPERLU_DIR)/include \n\
CPPFLAGS = -std=c++11 \n\
' $file"

# Add LAPACK and BLAS libraries
if $(is_c intel) ; then

    pack_cmd "sed -i '1 a\
LIBS += -lmkl_lapack95_lp64 -lmkl_blas95_lp64\n\
LIBS += -lmkl_intel_lp64 -lmkl_core -lmkl_sequential\n\
' $file"

elif $(is_c gnu) ; then
    tmp="-llapack"
    for la in $(choice linalg) ; do
	if [[ $(pack_installed $la) -eq 1 ]]; then
	    pack_set --mod-req $la
	    [[ "x$la" == "xatlas" ]] && tmp="$tmp -lf77blas -lcblas"
	    [[ "x$la" == "xacml" ]] && tmp=""
	    tmp="$tmp -l$la"
	    pack_cmd "sed -i '1 a\
LIBS += $(list -LD-rp $la) $tmp\n\
' $file"
	    break
	fi
    done

else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi

pack_cmd "sed -i '1 a\
LIBS = $(list -LD-rp superlu-dist parmetis scotch)\n\
LIBS += -lsuperlu -lptscotchparmetis -lptscotch -lptscotcherr \n\
LIBS += -lscotchmetis -lscotch -lscotcherr \n\
#\n\
#\n\
#\n\
#\n\
# Generate auto-dependencies\n\
%.d: %.c\n\
\t@set -e; rm -f \$@; \\\n\
\t\$(CC) -M \$(CCDEFS) \$(CFLAGS) \$< > \$@.\$\$\$\$; \\\n\
\tsed \'s,\\(\$*\\)\\.o[ :]*,\\1.o \$@ : ,g\' < \$@.\$\$\$\$ > \$@;\\\n\
\t\$(RM) \$(RMFLAGS) \$@.\$\$\$\$\n\
#\n\
%.d: %.cpp\n\
\t@set -e; rm -f \$@; \\\n\
\t\$(CXX) -M \$(CPPDEFS) \$(CXXFLAGS) \$< > \$@.\$\$\$\$; \\\n\
\tsed \'s,\\(\$*\\)\\.o[ :]*,\\1.o \$@ : ,g\' < \$@.\$\$\$\$ > \$@;\\\n\
\t\$(RM) \$(RMFLAGS) \$@.\$\$\$\$\n\
' $file"

pack_cmd "make all"

pack_cmd "cd fortran"
pack_cmd "make all"
