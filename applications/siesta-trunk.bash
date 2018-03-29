# 507 pre SOC
# 508 SOC
# 510 Transiesta
for v in 507 508 514 527 660 676 ; do

add_package --archive siesta-trunk-$v.tar.gz \
    --directory './~siesta-maint' \
    http://bazaar.launchpad.net/~siesta-maint/siesta/trunk/tarball/$v/index.html

pack_set -s $MAKE_PARALLEL

# Add the lua family
pack_set --module-opt "--lua-family siesta"

pack_set --install-query $(pack_get --prefix)/bin/hsx2hs

pack_set --module-requirement mpi --module-requirement netcdf


# Go into correct directory
# Sadly launchpad adds shit-loads of paths... :(
pack_cmd "cd siesta/trunk"


# Initial setup for new trunk with transiesta
if [[ $(vrs_cmp $v 510) -ge 0 ]]; then
    if [[ $(pack_installed flook) -eq 1 ]]; then
        pack_set --module-requirement flook
    fi

    # Fix the __FILE__ content in the classes
    pack_cmd 'for f in Src/class* Src/fdf/utils.F90 ; do sed -i -e "s:__FILE__:\"$f\":g" $f ; done'
    pack_cmd 'sed -i -e "s:__FILE__:Fstack.T90:g" Src/Fstack.T90'

else
    # Fix __FILE__
    pack_cmd 'f=Src/fdf/utils.F90 ; sed -i -e "s:__FILE__:\"$f\":g" $f'
    
fi

# Fix SOC
if [[ $(vrs_cmp $v 508) -eq 0 ]]; then
    pack_cmd "sed -i -e '634s:e_spin_dim:h_spin_dim:' Src/new_dm.F"
    pack_cmd "sed -i -e 's:cdiag.o:cdiag.o m_diagon_opt.o :' Util/TBTrans_rep/Makefile"
fi

# Change to directory:
pack_cmd "cd Obj"

# Setup the compilation scheme
pack_cmd "../Src/obj_setup.sh"

file=arch.make
prefix=$(pack_get --prefix)

pack_cmd "echo '# Compilation $(pack_get --version) on $(get_c)' > $file"
pack_cmd "echo 'PP = cpp -E -P -C -nostdinc' > $file"

# Add LTO in case of gcc-6.1 and above version 4.1
if [[ $(vrs_cmp $v 562) -ge 0 ]]; then
if $(is_c gnu) ; then
    if [[ $(vrs_cmp $(get_c --version) 6.1.0) -ge 0 ]]; then
	pack_cmd "sed -i '$ a\
LIBS += -flto -fuse-linker-plugin \n\
FC_SERIAL += -flto -fuse-linker-plugin\n\
FFLAGS += -flto -fuse-linker-plugin\n'" arch.make
    fi
fi
fi

fdict=libvardict.a
if [[ $(vrs_cmp $v 535) -ge 0 ]]; then
    fdict=libfdict.a
fi

if [[ $(vrs_cmp $v 510) -ge 0 ]]; then
    pack_set --module-requirement mumps
    pack_set --module-requirement fftw-3
    pack_cmd "sed -i '1 a\
METIS_LIB = -lmetis\n\
FFTW_PATH = $(pack_get --prefix fftw-3)\n\
FFTW_INCFLAGS = -I\$(FFTW_PATH)/include\n\
FFTW_LIBS = -L\$(FFTW_PATH)/lib -lfftw3 \$(METIS_LIB)\n\
LIBS += \$(METIS_LIB)\n\
FPPFLAGS += -DNCDF -DNCDF_4 -DNCDF_PARALLEL\n\
COMP_LIBS += libncdf.a $fdict' $file"

    pack_cmd "sed -i '1 a\
FPPFLAGS += -DSIESTA__METIS -DSIESTA__MUMPS -DTS_NOCHECKS\n\
ADDLIB += -lzmumps -lmumps_common -lesmumps -lscotch -lscotcherr -lpord -lparmetis -lmetis' $file"

else 
    if [[ $(pack_installed metis) -eq 1 ]]; then
	pack_set --module-requirement metis
	pack_cmd "sed -i '1 a\
FPPFLAGS += -DSIESTA__METIS\n\
ADDLIB += -lmetis' $file"
    fi
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
NETCDF_INCFLAGS=$(list --INCDIRS netcdf)\n\
NETCDF_LIBS=$(list --LD-rp netcdf)\n\
ADDLIB=-lnetcdff -lnetcdf -lpnetcdf -lhdf5_hl -lhdf5 -lz\n\
ADDLIB += #OMPPLACEHOLDER\n\
INCFLAGS = $(list --INCDIRS $(pack_get --mod-req))\n\
\n\
MPI_INTERFACE=libmpi_f90.a\n\
MPI_INCLUDE=.\n\
\n\
' $file"

if [[ $(pack_installed flook) -eq 1 ]]; then
    pack_cmd "sed -i '$ a\
FPPFLAGS += -DSIESTA__FLOOK \n\
FLOOK_LIB = $(list -LD-rp flook) -lflookall -ldl\n\
INCFLAGS += $(list -INCDIRS flook)\n\
LIBS += \$(FLOOK_LIB) \n' $file"
fi

# ELPA should be added before the linear algebra libraries
if [[ $(vrs_cmp $v 626) -ge 0 ]]; then
    pack_set --module-requirement elpa
    pack_cmd "sed -i '$ a\
FPPFLAGS += -DSIESTA__ELPA \n\
ELPA_LIB = $(list -LD-rp elpa) -lelpa\n\
INCFLAGS += $(list -INCDIRS elpa)/elpa\n\
LIBS += \$(ELPA_LIB) \n' $file"
fi

source applications/siesta-linalg.bash


function set_flag {
    local v=$1 ; shift
    end=
    case $v in
	openmp)
	    pack_cmd "sed -i -e 's/\(\#OMPPLACEHOLDER\)/$FLAG_OMP \1/g' $file"
	    pack_cmd "sed -i -e 's:-lzmumps :-lzmumps_omp :g' $file"
	    pack_cmd "sed -i -e 's:-lmumps_common :-lmumps_common_omp :g' $file"
	    
	    end=_omp
	    case $siesta_la in
		openblas)
		    pack_cmd "sed -i -e 's:$(pack_get -lib openblas):$(pack_get -lib[omp] openblas) :g' $file"
		    ;;
		mkl)
		    pack_cmd "sed -i -e 's:-lmkl_sequential:-lmkl_intel_thread:g' $file"
		    ;;
	    esac
	    ;;
	*)
	    pack_cmd "sed -i -e 's/$FLAG_OMP.*/\#OMPPLACEHOLDER/g' $file"
	    pack_cmd "sed -i -e 's:-l\(zmumps\)[^ ]* :-l\1 :g' $file"
	    pack_cmd "sed -i -e 's:-l\(mumps_common\)[^ ]* :-l\1 :g' $file"
	    
	    end=
	    case $siesta_la in
		openblas)
		    pack_cmd "sed -i -e 's:$(pack_get -lib[omp] openblas):$(pack_get -lib openblas):g' $file"
		    ;;
		mkl)
		    pack_cmd "sed -i -e 's:-lmkl_intel_thread:-lmkl_sequential:g' $file"
		    ;;
	    esac
	    ;;
    esac
}


pack_cmd "mkdir -p $(pack_get --prefix)/bin"

# Save the arch.make file
pack_cmd "cp $file $(pack_get --prefix)/$file"

# Shorthand for compiling utilities
function make_files {
    while [ $# -gt 0 ]; do
	local v=$1 ; shift
	pack_cmd "make $v"
	pack_cmd "cp $v $(pack_get --prefix)/bin/"
    done
}

# We split this into two segments... One with
# the old way, and one with the new utilities etc.
if [[ $(vrs_cmp $v 510) -ge 0 ]]; then
    # new transiesta-merge
    
for omp in openmp none ; do
    
    set_flag $omp
    
    # Ensure it is clean...
    pack_cmd "make clean"
    
    # This should ensure a correct handling of the version info...
    pack_cmd "make $(get_make_parallel) siesta ; make siesta"
    pack_cmd "cp siesta $(pack_get --prefix)/bin/siesta$end"

    if [ $(vrs_cmp $v 655) -ge 0 ]; then 
	pack_cmd "echo '#!/bin/sh' > $prefix/bin/transiesta$end"
	pack_cmd "echo '$prefix/bin/siesta$end --electrode \$@' >> $prefix/bin/transiesta$end"
	pack_cmd "chmod a+x $prefix/bin/transiesta$end"
    else
	pack_cmd "make clean"
	
	pack_cmd "make $(get_make_parallel) transiesta ; make transiesta"
	pack_cmd "cp transiesta $(pack_get --prefix)/bin/transiesta$end"
    fi
    
done

pack_cmd "cd ../Util/Bands"
make_files gnubands eigfat2plot fat.gplot gnubands

pack_cmd "cd ../Contrib/APostnikov"
pack_cmd "make all"
pack_cmd "cp *xsf fmpdos $(pack_get --prefix)/bin/"

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
pack_cmd "cp tselecs.sh $(pack_get --prefix)/bin/"

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
    pack_cmd "cp tbtrans $(pack_get --prefix)/bin/tbtrans$end"
    pack_cmd "make clean-tbt ; make $(get_make_parallel) phtrans"
    pack_cmd "make phtrans" # corrects version 
    pack_cmd "cp phtrans $(pack_get --prefix)/bin/phtrans$end"
    pack_cmd "make clean"
    
done
pack_cmd "cd ../"

# end TS

pack_cmd "cd ../VCA"
make_files mixps fractional

pack_cmd "cd ../Vibra/Src"
make_files fcbuild vibra

pack_cmd "cd ../../WFS"
make_files info_wfsx readwf readwfx wfs2wfsx wfsx2wfs


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
    pack_cmd "echo '' >> $file ; echo 'FPPFLAGS += -DUSE_GEMM3M' >> $file"
    for omp in openmp none ; do

	set_flag $omp
	if [ $(vrs_cmp $v 655) -ge 0 ]; then
	    pack_cmd "echo '#!/bin/sh' > $prefix/bin/transiesta${end}_3m"
	    pack_cmd "echo '$prefix/bin/siesta$end --electrode \$@' >> $prefix/bin/transiesta${end}_3m"
	    pack_cmd "chmod a+x $prefix/bin/transiesta${end}_3m"
	else
	    pack_cmd "make clean"
	    
	    pack_cmd "make $(get_make_parallel) transiesta ; make transiesta"
	    pack_cmd "cp transiesta $(pack_get --prefix)/bin/transiesta${end}_3m"
	fi
	
	pack_cmd "pushd ../Util/TS/TBtrans ; make clean"
	pack_cmd "make $(get_make_parallel) ; make"
	pack_cmd "cp tbtrans $(pack_get --prefix)/bin/tbtrans${end}_3m"
	pack_cmd "make clean-tbt ; make $(get_make_parallel) phtrans ; make phtrans"
	pack_cmd "cp phtrans $(pack_get --prefix)/bin/phtrans${end}_3m"
	pack_cmd "make clean"
	pack_cmd "popd"

    done
fi

else

    # This should ensure a correct handling of the version info...
    source applications/siesta-speed.bash libSiestaXC.a siesta
    pack_cmd "cp siesta $(pack_get --prefix)/bin/"
    
    pack_cmd "make clean"
    
    source applications/siesta-speed.bash libSiestaXC.a transiesta
    pack_cmd "cp transiesta $(pack_get --prefix)/bin/"

    pack_cmd "cd ../Util/Contrib/APostnikov"
    pack_cmd "make all"
    pack_cmd "cp *xsf fmpdos $(pack_get --prefix)/bin/"

    #pack_cmd "cd ../../Denchar/Src"
    #pack_cmd "make denchar"
    #pack_cmd "cp denchar $(pack_get --prefix)/bin/"

    pack_cmd "cd ../../Eig2DOS"
    pack_cmd "make"
    pack_cmd "cp Eig2DOS $(pack_get --prefix)/bin/"

    pack_cmd "cd ../HSX"
    pack_cmd "make hs2hsx hsx2hs"
    pack_cmd "cp hs2hsx hsx2hs $(pack_get --prefix)/bin/"

    pack_cmd "cd ../TBTrans"
    pack_cmd "make"
    pack_cmd "cp tbtrans $(pack_get --prefix)/bin/tbtrans_orig"

    pack_cmd "cd ../TBTrans_rep"
    pack_cmd "make"
    pack_cmd "cp tbtrans $(pack_get --prefix)/bin/tbtrans"

    pack_cmd "cd ../WFS"
    pack_cmd "make info_wfsx readwf readwfx wfs2wfsx wfsx2wfs"
    pack_cmd "cp info_wfsx $(pack_get --prefix)/bin/"
    pack_cmd "cp readwf readwfx $(pack_get --prefix)/bin/"
    pack_cmd "cp wfs2wfsx wfsx2wfs $(pack_get --prefix)/bin/"

    pack_cmd "cd ../Vibra/Src"
    pack_cmd "make"
    pack_cmd "cp fcbuild vibra $(pack_get --prefix)/bin/"

    pack_cmd "cd ../../"
    pack_cmd "$FC $FCFLAGS vpsa2bin.f -o $(pack_get --prefix)/bin/vpsa2bin"
    pack_cmd "$FC $FCFLAGS vpsb2asc.f -o $(pack_get --prefix)/bin/vpsb2asc"
fi

unset set_flag
unset make_files
pack_cmd "chmod a+x $(pack_get --prefix)/bin/*"

done
