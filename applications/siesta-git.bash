#pack_set -s $MAKE_PARALLEL

# Add the lua family
pack_set -module-opt "--lua-family siesta"

pack_set -install-query /always/install/this/module

pack_set -module-requirement mpi -module-requirement netcdf


# Initial setup for new trunk with transiesta
if [[ $(pack_installed flook) -eq 1 ]]; then
    pack_set -module-requirement flook
fi

# Fix the __FILE__ content in the classes
pack_cmd 'for f in Src/class* Src/fdf/utils.F90 ; do sed -i -e "s:__FILE__:\"$f\":g" $f ; done'
pack_cmd 'sed -i -e "s:__FILE__:Fstack.T90:g" Src/Fstack.T90'

# override version.info
pack_cmd "git describe --always > version.info"

# Fix SpPivot
pack_cmd 'sed -i -e "s/\(-o pvtsp \$(OBJS)\)/\1 \$(LIBS)/g" Util/SpPivot/Makefile'
# Remove vnl-operator compilation
pack_cmd "sed -i -e '/Pseudo\/vnl-operator/d' Makefile"

# Change to directory:
pack_cmd "mkdir -p Obj ; cd Obj"

# Setup the compilation scheme
pack_cmd "../Config/obj_setup.sh"
# remove the LIBS= line
pack_cmd "sed -i -e '/^LIBS=\s*$/d' build.mk"
pack_cmd "sed -i -e '/^FPPFLAGS=\s*$/d' build.mk"

prefix=$(pack_get -prefix)

pack_cmd "echo '# Compilation $(pack_get -version) on $(get_c)' > arch.make"

pack_cmd "sed -i '$ a\
SIESTA_INSTALL_DIRECTORY = $prefix\n\
PP = cpp -E -P -C -nostdinc\n\
WITH_PSML = 1\n\
WITH_LIBXC = 1\n\
WITH_GRIDXC = 1\n\
WITH_MPI = 1\n\
WITH_ELPA = 1\n\
WITH_FLOOK = 1\n\
WITH_NETCDF = 1\n\
WITH_NCDF = 1\n\
WITH_NCDF_PARALLEL = 1\n\
WITH_EXTRA_FPPFLAGS += TS_NOCHECKS\n' arch.make"

# Add LTO in case of gcc-6.1 and above version 4.1
# We need to fix LTO compilation for MatrixSwitch library
# I have problems with GCC 9.1.0
#if $(is_c gnu) ; then
#    if [[ $(vrs_cmp $(get_c --version) 6.1.0) -ge 0 ]]; then
#	pack_cmd "sed -i '$ a\
#LIBS += -flto -fuse-linker-plugin \n\
#FC_SERIAL += -flto -fuse-linker-plugin\n\
#FFLAGS += -flto -fuse-linker-plugin\n'" arch.make
#    fi
#fi

pack_set -module-requirement fftw
pack_cmd "sed -i '$ a\
FFTW_ROOT = $(pack_get -prefix fftw)\n\
FFTW_INCFLAGS = -I\$(FFTW_ROOT)/include\n\
FFTW_LIBS = -L\$(FFTW_ROOT)/lib -lfftw3\n' arch.make"

if [[ $(pack_installed mumps) -eq 1 ]]; then
    pack_set -module-requirement mumps
    pack_cmd "sed -i '$ a\
METIS_LIB = $(list -LD-rp metis) -lmetis\n\
LIBS += \$(METIS_LIB)\n\
WITH_EXTRA_FPPFLAGS += SIESTA__METIS SIESTA__MUMPS\n\
LIBS += $(list -LD-rp mumps) -lzmumps -lmumps_common -lesmumps -lscotch -lscotcherr -lpord -lparmetis -lmetis' arch.make"

elif [[ $(pack_installed metis) -eq 1 ]]; then
    pack_set -module-requirement metis
    pack_cmd "sed -i '$ a\
METIS_LIB = $(list -LD-rp metis) -lmetis\n\
LIBS += \$(METIS_LIB)\n\
WITH_EXTRA_FPPFLAGS += SIESTA__METIS' arch.make"
fi

pack_set -module-requirement libgridxc
pack_set -module-requirement libpsml
pack_set -module-requirement xmlf90
pack_cmd "sed -i '$ a\
LIBXC_ROOT = $(pack_get -prefix libxc)\n\
XMLF90_ROOT = $(pack_get -prefix xmlf90)\n\
GRIDXC_ROOT = $(pack_get -prefix libgridxc)\n\
GRIDXC_CONFIG_PREFIX = dp\n\
PSML_ROOT = $(pack_get -prefix libpsml)\n\
LIBS += -Wl,-rpath=$(pack_get -LD libxc)\n\
LIBS += -Wl,-rpath=$(pack_get -LD xmlf90)\n\
LIBS += -Wl,-rpath=$(pack_get -LD libpsml)\n\
LIBS += -Wl,-rpath=$(pack_get -LD libgridxc)\n' arch.make"


pack_cmd "sed -i '1 a\
.SUFFIXES:\n\
.SUFFIXES: .f .F .o .a .f90 .F90 .c\n\
SIESTA_ARCH=x86_64-linux-$(get_hostname)\n\
\n\
FPP=$MPIFC\n\
FPP_OUTPUT= \n\
CC=$CC\n\
FC_PARALLEL=$MPIFC\n\
FC_SERIAL=$FC\n\
#FC=$MPIFC\n\
AR=$AR\n\
RANLIB=$RANLIB\n\
\n\
FFLAGS = $FFLAGS\n\
FFLAGS += #OMPPLACEHOLDER\n\
\n\
ARFLAGS_EXTRA=\n\
\n\
WITH_EXPLICIT_NETCDF_SYMBOLS = 1\n\
NETCDF_INCFLAGS=$(list -INCDIRS netcdf)\n\
NETCDF_LIBS = $(list -LD-rp netcdf)\n\
NETCDF_LIBS +=-lnetcdff -lnetcdf -lpnetcdf -lhdf5_hl -lhdf5 -lz\n\
LIBS += #OMPPLACEHOLDER\n\
INCFLAGS += $(list -INCDIRS $(pack_get -mod-req))\n\
\n' arch.make"

if [[ $(pack_installed flook) -eq 1 ]]; then
    pack_cmd "sed -i '$ a\
WITH_FLOOK = 1\n\
FLOOK_ROOT = $(pack_get -prefix flook)\n\
LIBS += $(list -LD-rp flook)\n' arch.make"
fi

# ELPA should be added before the linear algebra libraries
pack_set -module-requirement elpa
pack_cmd "sed -i '$ a\
WITH_ELPA = 1\n\
ELPA_ROOT = $(pack_get -prefix elpa)\n\
ELPA_INCLUDE_DIRECTORY = \$(ELPA_ROOT)/include/elpa\n\
INCFLAGS += $(list -INCDIRS elpa)\n\
LIBS += $(list -LD-rp elpa) \n' arch.make"

source applications/siesta-linalg.bash
pack_cmd "sed -i '$ a\
LDFLAGS += \$(LIBS)\n' arch.make"

function set_flag {
    local v=$1 ; shift
    end=
    case $v in
	openmp)
	    pack_cmd "sed -i -e 's/\(\#OMPPLACEHOLDER\)/$FLAG_OMP \1/g' arch.make"
	    # This will work regardless of MUMPS is used
	    pack_cmd "sed -i -e 's:-lzmumps :-lzmumps_omp :g' arch.make"
	    pack_cmd "sed -i -e 's:-lmumps_common :-lmumps_common_omp :g' arch.make"
	    pack_cmd "sed -i -e 's:$(pack_get -lib elpa):$(pack_get -lib[omp] elpa) :g' $file"

	    end=_omp
	    case $siesta_la in
		mkl)
		    pack_cmd "sed -i -e 's:-lmkl_sequential:-lmkl_intel_thread:g' arch.make"
		    ;;
		*)
		    pack_cmd "sed -i -e 's:$(pack_get -lib $siesta_la):$(pack_get -lib[omp] $siesta_la) :g' $file"
		    ;;
	    esac
	    ;;
	*)
	    pack_cmd "sed -i -e 's/$FLAG_OMP.*/\#OMPPLACEHOLDER/g' arch.make"
	    # This will work regardless of MUMPS is used
	    pack_cmd "sed -i -e 's:-l\(zmumps\)[^ ]* :-l\1 :g' arch.make"
	    pack_cmd "sed -i -e 's:-l\(mumps_common\)[^ ]* :-l\1 :g' arch.make"
	    pack_cmd "sed -i -e 's:$(pack_get -lib[omp] elpa):$(pack_get -lib elpa) :g' $file"

	    end=
	    case $siesta_la in
		mkl)
		    pack_cmd "sed -i -e 's:-lmkl_intel_thread:-lmkl_sequential:g' arch.make"
		    ;;
		*)
		    pack_cmd "sed -i -e 's:$(pack_get -lib[omp] $siesta_la):$(pack_get -lib $siesta_la):g' arch.make"
		    ;;
	    esac
	    ;;
    esac
}


# Save the arch.make file
pack_cmd "cp arch.make $prefix/arch.make"

# Compile the 3m equivalent versions, if applicable
case $siesta_la in
    mkl|openblas)
	tmp=1
	;;
    *)
	tmp=0
	;;
esac

pack_cmd "make install_utils"
pack_cmd "cp ../Util/TS/tselecs.sh $prefix/bin/"


if [[ $tmp -eq 1 ]]; then
    # Go back
    pack_cmd "echo '' >> arch.make ; echo 'FPPFLAGS += -DUSE_GEMM3M' >> arch.make"
    for omp in openmp none ; do

	set_flag $omp
	end=${end}_3m

	# Ensure it is clean...
	pack_cmd "make clean"
    
	# This should ensure a correct handling of the version info...
	pack_cmd "make $(get_make_parallel) install_siesta"
	[ -n "$end" ] && pack_cmd "mv $prefix/bin/siesta $prefix/bin/siesta$end"

	pack_cmd "echo '#!/bin/sh' > $prefix/bin/transiesta$end"
	pack_cmd "echo '$prefix/bin/siesta$end --electrode \$@' >> $prefix/bin/transiesta$end"

	pack_cmd "make Util/TS/TBtrans MODE=clean"

	pack_cmd "make Util/TS/TBtrans $(get_make_parallel)"
	pack_cmd "cp Util/TS/TBtrans/tbtrans $prefix/bin/tbtrans$end"

	pack_cmd "make Util/TS/TBtrans MODE=clean"

	pack_cmd "make Util/TS/TBtrans $(get_make_parallel) MODE=phtrans"
	pack_cmd "cp Util/TS/TBtrans/phtrans $prefix/bin/phtrans$end"

    done
fi


# remove setting again
pack_cmd "sed -i -e '/USE_GEMM3M/d' arch.make"


# We split this into two segments... One with
# the old way, and one with the new utilities etc.
for omp in openmp none ; do
    
    set_flag $omp
    
    # Ensure it is clean...
    pack_cmd "make clean"
    
    # This should ensure a correct handling of the version info...
    pack_cmd "make $(get_make_parallel) install_siesta"
    [ -n "$end" ] && pack_cmd "mv $prefix/bin/siesta $prefix/bin/siesta$end"

    pack_cmd "echo '#!/bin/sh' > $prefix/bin/transiesta$end"
    pack_cmd "echo '$prefix/bin/siesta$end --electrode \$@' >> $prefix/bin/transiesta$end"
    

    pack_cmd "make Util/TS/TBtrans MODE=clean"
   
    pack_cmd "make Util/TS/TBtrans $(get_make_parallel)"
    [ -n "$end" ] && pack_cmd "cp Util/TS/TBtrans/tbtrans $prefix/bin/tbtrans$end"

    pack_cmd "make Util/TS/TBtrans MODE=clean"

    pack_cmd "make Util/TS/TBtrans $(get_make_parallel) MODE=phtrans"
    [ -n "$end" ] && pack_cmd "cp Util/TS/TBtrans/phtrans $prefix/bin/phtrans$end"
    
done

unset set_flag
unset make_files
pack_cmd "chmod a+x $prefix/bin/*"
