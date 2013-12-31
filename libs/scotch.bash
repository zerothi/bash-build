add_package --package scotch --alias scotch --version 6.0.0 \
    https://gforge.inria.fr/frs/download.php/31832/scotch_6.0.0_esmumps.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libscotch.a

pack_set --module-requirement zlib --module-requirement openmpi

if [ $(pack_installed bison) -eq 1 ]; then
    pack_set --command "module load $(pack_get --module-name-requirement bison) $(pack_get --module-name bison)"
fi
if [ $(pack_installed flex) -eq 1 ]; then
    pack_set --command "module load $(pack_get --module-name-requirement flex) $(pack_get --module-name flex)"
fi

# Move to source
pack_set --command "cd src"


file=Makefile.inc
pack_set --command "echo '# Makefile for easy installation ' > $file"


if $(is_c intel) ; then

    pack_set --command "sed -i '1 a\
CFLAGS = -restrict' $file"
    
elif $(is_c gnu) ; then
    
    pack_set --command "sed -i '1 a\
CFLAGS = -Drestrict=__restrict' $file"
    
else
    doerr scotch "Unrecognized compiler"
fi

pack_set --command "sed -i '1 a\
EXE = \n\
LIB = .a \n\
OBJ = .o \n\
MAKE = make \n\
AR = $AR \n\
ARFLAGS = -ruv \n\
CAT = cat \n\
CCS = $CC \n\
CCP = $MPICC \n\
CCD = $CC $(list --INCDIRS openmpi) \n\
CFLAGS += $CFLAGS -DCOMMON_FILE_COMPRESS_GZ -DCOMMON_PTHREAD -DCOMMON_RANDOM_FIXED_SEED -DSCOTCH_RENAME -DSCOTCH_PTHREAD -DIDXSIZE64 \n\
CLIBFLAGS = \n\
LDFLAGS = $(list --LDFLAGS --Wlrpath zlib) $(list --LDFLAGS --Wlrpath openmpi) -lz -lm -lrt \n\
CP = cp \n\
LEX = flex -Pscotchyy -olex.yy.c \n\
LN = ln \n\
MKDIR = mkdir \n\
RANLIB = ranlib \n\
YACC = bison -pscotchyy -y -b y \n\
\n\
prefix = $(pack_get --install-prefix)\n\
\n' $file"

# Make commands
pack_set --command "make $(get_make_parallel) scotch"
pack_set --command "make $(get_make_parallel) ptscotch"
# the makefile does not create the directory...
pack_set --command "mkdir -p $(pack_get --install-prefix)"
pack_set --command "make install"

if [ $(pack_installed flex) -eq 1 ] ; then
    pack_set --command "module unload $(pack_get --module-name flex) $(pack_get --module-name-requirement flex)"
fi
if [ $(pack_installed bison) -eq 1 ] ; then
    pack_set --command "module unload $(pack_get --module-name bison) $(pack_get --module-name-requirement bison)"
fi
