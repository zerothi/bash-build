pack_set -s $MAKE_PARALLEL

# Add the lua family
pack_set -module-opt "--lua-family siesta"

pack_set -install-query $(pack_get -prefix)/bin/hsx2hs

pack_set -module-requirement mpi -module-requirement netcdf


# Initial setup for new trunk with transiesta
if [[ $(pack_installed flook) -eq 1 ]]; then
    pack_set -module-requirement flook
fi

# Fix the __FILE__ content in the classes
pack_cmd 'for f in Src/class* Src/fdf/utils.F90 ; do sed -i -e "s:__FILE__:\"$f\":g" $f ; done'
pack_cmd 'sed -i -e "s:__FILE__:Fstack.T90:g" Src/Fstack.T90'

# Change to directory:
pack_cmd "cd Obj"

# Setup the compilation scheme
pack_cmd "../Src/obj_setup.sh"

prefix=$(pack_get -prefix)

pack_cmd "echo '# Compilation $(pack_get -version) on $(get_c)' > arch.make"
pack_cmd "echo 'PP = cpp -E -P -C -nostdinc' > arch.make"

# Add LTO in case of gcc-6.1 and above version 4.1
if $(is_c gnu) ; then
    if [[ $(vrs_cmp $(get_c --version) 6.1.0) -ge 0 ]]; then
	pack_cmd "sed -i '$ a\
LIBS += -flto -fuse-linker-plugin \n\
FC_SERIAL += -flto -fuse-linker-plugin\n\
FFLAGS += -flto -fuse-linker-plugin\n'" arch.make
    fi
fi

pack_set -module-requirement fftw
pack_cmd "sed -i '$ a\
FFTW_PATH = $prefix\n\
FFTW_INCFLAGS = -I\$(FFTW_PATH)/include\n\
FFTW_LIBS = -L\$(FFTW_PATH)/lib -lfftw3\n\
FPPFLAGS += -DNCDF -DNCDF_4 -DNCDF_PARALLEL -DTS_NOCHECKS\n\
COMP_LIBS += libncdf.a libfdict.a' arch.make"

if [[ $(pack_installed mumps) -eq 1 ]]; then
    pack_set -module-requirement mumps
    pack_cmd "sed -i '$ a\
METIS_LIB = -lmetis\n\
LIBS += \$(METIS_LIB)\n\
FPPFLAGS += -DSIESTA__METIS -DSIESTA__MUMPS\n\
ADDLIB += -lzmumps -lmumps_common -lesmumps -lscotch -lscotcherr -lpord -lparmetis -lmetis' arch.make"

elif [[ $(pack_installed metis) -eq 1 ]]; then
    pack_set -module-requirement metis
    pack_cmd "sed -i '$ a\
METIS_LIB = -lmetis\n\
LIBS += \$(METIS_LIB)\n\
FPPFLAGS += -DSIESTA__METIS' arch.make"
fi


pack_cmd "sed -i '1 a\
.SUFFIXES:\n\
.SUFFIXES: .f .F .o .a .f90 .F90 .c\n\
SIESTA_ARCH=x86_64-linux-$(get_hostname)\n\
\n\
FPP=$MPIFC\n\
FPP_OUTPUT= \n\
CC=$CC\n\
FC=$MPIFC\n\
FC_SERIAL=$FC\n\
AR=$AR\n\
RANLIB=$RANLIB\n\
SYS=nag\n\
SP_KIND=4\n\
DP_KIND=8\n\
KINDS=\$(SP_KIND) \$(DP_KIND)\n\
\n\
FFLAGS=$FCFLAGS\n\
FFLAGS += #OMPPLACEHOLDER\n\
FPPFLAGS += -DMPI -DFC_HAVE_FLUSH -DFC_HAVE_ABORT -DCDF -DCDF4\n\
\n\
ARFLAGS_EXTRA=\n\
\n\
NETCDF_INCFLAGS=$(list -INCDIRS netcdf)\n\
NETCDF_LIBS=$(list -LD-rp netcdf)\n\
ADDLIB=-lnetcdff -lnetcdf -lpnetcdf -lhdf5_hl -lhdf5 -lz\n\
ADDLIB += #OMPPLACEHOLDER\n\
INCFLAGS = $(list -INCDIRS $(pack_get -mod-req))\n\
\n\
MPI_INTERFACE=libmpi_f90.a\n\
MPI_INCLUDE=.\n\
\n\
' arch.make"

if [[ $(pack_installed flook) -eq 1 ]]; then
    pack_cmd "sed -i '$ a\
FPPFLAGS += -DSIESTA__FLOOK \n\
FLOOK_LIB = $(list -LD-rp flook) -lflookall -ldl\n\
INCFLAGS += $(list -INCDIRS flook)\n\
LIBS += \$(FLOOK_LIB) \n' arch.make"
fi

# ELPA should be added before the linear algebra libraries
pack_set -module-requirement elpa
pack_cmd "sed -i '$ a\
FPPFLAGS += -DSIESTA__ELPA \n\
ELPA_LIB = $(list -LD-rp elpa) $(pack_get -lib elpa)\n\
INCFLAGS += $(list -INCDIRS elpa)/elpa\n\
LIBS += \$(ELPA_LIB) \n' arch.make"

source applications/siesta-linalg.bash


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


pack_cmd "mkdir -p $prefix/bin"

# Save the arch.make file
pack_cmd "cp arch.make $prefix/arch.make"

# Shorthand for compiling utilities
function make_files {
    while [ $# -gt 0 ]; do
	local v=$1 ; shift
	pack_cmd "make $v"
	pack_cmd "cp $v $prefix/bin/"
    done
}

# We split this into two segments... One with
# the old way, and one with the new utilities etc.
for omp in openmp none ; do
    
    set_flag $omp
    
    # Ensure it is clean...
    pack_cmd "make clean"
    
    # This should ensure a correct handling of the version info...
    pack_cmd "make $(get_make_parallel) siesta ; make siesta"
    pack_cmd "cp siesta $prefix/bin/siesta$end"

    pack_cmd "echo '#!/bin/sh' > $prefix/bin/transiesta$end"
    pack_cmd "echo '$prefix/bin/siesta$end --electrode \$@' >> $prefix/bin/transiesta$end"
    pack_cmd "chmod a+x $prefix/bin/transiesta$end"
    
done

pack_cmd "cd ../Util/Bands"
make_files gnubands eigfat2plot fat.gplot gnubands

pack_cmd "cd ../Contrib/APostnikov"
pack_cmd "make all"
pack_cmd "cp *xsf fmpdos $prefix/bin/"

pack_cmd "cd ../../COOP"
make_files mprop fat

pack_cmd "cd ../Denchar/Src"
make_files denchar

pack_cmd "cd ../../Eig2DOS"
make_files Eig2DOS

pack_cmd "cd ../Gen-basis"
make_files gen-basis ioncat

pack_cmd "cd ../Grid"
make_files grid2val grid2cube grid_rotate grid_supercell

pack_cmd "cd ../Grimme/"
make_files fdf2grimme

pack_cmd "cd ../HSX"
make_files hs2hsx hsx2hs

pack_cmd "cd ../Optimizer"
make_files swarm simplex

pack_cmd "cd ../Projections"
make_files orbmol_proj

pack_cmd "cd ../SpPivot"
make_files pvtsp

pack_cmd "cd ../STM/simple-stm"
make_files plstm
pack_cmd "cd ../ol-stm/Src"
make_files stm
pack_cmd "cd ../../"

# Install TS sub-directory...
pack_cmd "cd ../TS/"
pack_cmd "cp tselecs.sh $prefix/bin/"

pack_cmd "cd ts2ts"
make_files ts2ts

pack_cmd "cd ../tshs2tshs/"
make_files tshs2tshs

pack_cmd "cd ../TBtrans/"
for omp in openmp none ; do
    
    pack_cmd "pushd ../../../Obj"
    set_flag $omp
    pack_cmd "popd ; make clean"
    pack_cmd "make $(get_make_parallel)"
    pack_cmd "make" # corrects version 
    pack_cmd "cp tbtrans $prefix/bin/tbtrans$end"
    pack_cmd "make clean-tbt ; make $(get_make_parallel) phtrans"
    pack_cmd "make phtrans" # corrects version 
    pack_cmd "cp phtrans $prefix/bin/phtrans$end"
    pack_cmd "make clean"
    
done
pack_cmd "cd ../"

# end TS

pack_cmd "cd ../VCA"
make_files mixps fractional

pack_cmd "cd ../Vibra/Src"
make_files fcbuild vibra

pack_cmd "cd ../../WFS"
make_files readwf readwfx wfs2wfsx wfsx2wfs


# Compile the 3m equivalent versions, if applicable
pack_cmd "cd ../../Obj"
case $siesta_la in
    mkl|openblas)
	tmp=1
	;;
    *)
	tmp=0
	;;
esac

if [[ $tmp -eq 1 ]]; then
    # Go back
    pack_cmd "echo '' >> arch.make ; echo 'FPPFLAGS += -DUSE_GEMM3M' >> arch.make"
    for omp in openmp none ; do

	set_flag $omp
	if [ $(vrs_cmp $v 655) -ge 0 ]; then
	    pack_cmd "echo '#!/bin/sh' > $prefix/bin/transiesta${end}_3m"
	    pack_cmd "echo '$prefix/bin/siesta$end --electrode \$@' >> $prefix/bin/transiesta${end}_3m"
	    pack_cmd "chmod a+x $prefix/bin/transiesta${end}_3m"
	else
	    pack_cmd "make clean"
	    
	    pack_cmd "make $(get_make_parallel) transiesta ; make transiesta"
	    pack_cmd "cp transiesta $prefix/bin/transiesta${end}_3m"
	fi
	
	pack_cmd "pushd ../Util/TS/TBtrans ; make clean"
	pack_cmd "make $(get_make_parallel) ; make"
	pack_cmd "cp tbtrans $prefix/bin/tbtrans${end}_3m"
	pack_cmd "make clean-tbt ; make $(get_make_parallel) phtrans ; make phtrans"
	pack_cmd "cp phtrans $prefix/bin/phtrans${end}_3m"
	pack_cmd "make clean"
	pack_cmd "popd"

    done
fi

unset set_flag
unset make_files
pack_cmd "chmod a+x $prefix/bin/*"
