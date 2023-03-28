# MUMPS 4.10.0 only works with 5.1.12b, MUMPS 5 works with >=6.0.1
for v in 7.0.3 ; do
add_package --package scotch --alias scotch --version $v \
	    https://gitlab.inria.fr/scotch/scotch/-/archive/v$v/scotch-v$v.tar.bz2

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libscotch.a

pack_set --module-requirement zlib --module-requirement mpi

pack_set --lib "-lscotch -lscotcherr -lscotcherrexit"
pack_set --lib[pt] "-lptscotch -lptscotcherr -lptscotcherrexit"


if [[ $(pack_installed bison) -eq 1 ]]; then
    pack_cmd "module load $(list -mod-names ++bison)"
fi
if [[ $(pack_installed flex) -eq 1 ]]; then
    pack_cmd "module load $(list -mod-names ++flex)"
fi

# Move to source
pack_cmd "cd src"

file=Makefile.inc
pack_cmd "echo '# Makefile for easy installation ' > $file"

if $(is_c intel) ; then

    pack_cmd "sed -i '1 a\
CFLAGS = -restrict\n' $file"
    
elif $(is_c gnu) ; then
    
    pack_cmd "sed -i '1 a\
CFLAGS = -Drestrict=__restrict\n' $file"
    
fi

# We have
#CFLAGS += -DSCOTCH_METIS_PREFIX
# above will prefix with SCOTCH_*
#CFLAGS += -DSCOTCH_METIS_VERSION=5
# make compatibility with APIv5 of METIS.

pack_cmd "sed -i '$ a\
EXE = \n\
LIB = .a \n\
OBJ = .o \n\
MAKE = make \n\
AR = $AR \n\
ARFLAGS = -ruv \n\
CAT = cat \n\
CCS = $CC \n\
CCP = $MPICC \n\
CCD = $CC $(list --INCDIRS mpi) \n\
CFLAGS += $CFLAGS -DCOMMON_FILE_COMPRESS_GZ -DCOMMON_RANDOM_FIXED_SEED -DSCOTCH_RENAME -DIDXSIZE64 \n\
CFLAGS += -DCOMMON_PTHREAD -DSCOTCH_PTHREAD\n\
CFLAGS += -DSCOTCH_METIS_PREFIX\n\
CFLAGS += -DSCOTCH_METIS_VERSION=5\n\
CLIBFLAGS = \n\
LDFLAGS = $(list --LD-rp +mpi) -lz -lm -lrt -lpthread \n\
CP = cp \n\
LEX = flex -Pscotchyy -olex.yy.c \n\
LN = ln \n\
MKDIR = mkdir \n\
RANLIB = ranlib \n\
YACC = bison -pscotchyy -y -b y \n\
\n\
prefix = $(pack_get --prefix)\n\
\n' $file"

# the makefile does not create the directory...
pack_cmd "mkdir -p $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel) ptscotch"
if [[ $(vrs_cmp $v 6.0.0) -gt 0 ]]; then
    pack_cmd "make $(get_make_parallel) ptesmumps"
fi
pack_cmd "make install"
# this check waits for a key-press????
#pack_cmd "make ptcheck > scotch.test 2>&1"
#pack_store scotch.test scotch.test.p
pack_cmd "make clean"

# Remove threads
pack_cmd "sed -i -e 's/-DSCOTCH_PTHREAD//gi' $file"
pack_cmd "sed -i -e 's/-DCOMMON_PTHREAD//gi' $file"
pack_cmd "sed -i -e 's/-lpthread//gi' $file"
pack_cmd "make $(get_make_parallel) scotch"
if [[ $(vrs_cmp $v 6.0.0) -gt 0 ]]; then
    pack_cmd "make $(get_make_parallel) esmumps"
fi
#pack_cmd "make check > scotch.test 2>&1"
pack_cmd "make install"
#pack_store scotch.test

if [[ $(vrs_cmp $v 6.0.0) -gt 0 ]]; then
    # the esmumps libraries are not "installed"
    pack_cmd "cd ../lib"
    pack_cmd "cp libesmumps.a libptesmumps.a $(pack_get -LD)/"
    pack_cmd "cd ../include"
    pack_cmd "cp esmumps.h $(pack_get -prefix)/include/"
    pack_cmd "cp metis.h $(pack_get -prefix)/include/scotch_metis.h"
    pack_cmd "cp parmetis.h $(pack_get -prefix)/include/scotch_parmetis.h"
fi

if [[ $(pack_installed flex) -eq 1 ]] ; then
    pack_cmd "module unload $(list -mod-names ++flex)"
fi
if [[ $(pack_installed bison) -eq 1 ]] ; then
    pack_cmd "module unload $(list -mod-names ++bison)"
fi

done
