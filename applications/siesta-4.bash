for v in 4.1-b1 ; do

bv=$(str_version -1 $v).$(str_version -2 $v)
add_package --archive siesta-$v.tar.gz \
	    --package siesta \
	    --version $v \
	    https://launchpad.net/siesta/$bv/$v/+download/siesta-$v.tgz

pack_set -s $MAKE_PARALLEL

# Add the lua family
pack_set --module-opt "--lua-family siesta"

pack_set --install-query $(pack_get --prefix)/bin/hsx2hs

pack_set --module-requirement mpi --module-requirement netcdf

pack_set --module-requirement flook

# Fix the __FILE__ content in the classes
pack_cmd 'for f in Src/class* Src/fdf/utils.F90 ; do sed -i -e "s:__FILE__:\"$f\":g" $f ; done'
pack_cmd 'sed -i -e "s:__FILE__:Fstack.T90:g" Src/Fstack.T90'

# Change to directory:
pack_cmd "cd Obj"

# Setup the compilation scheme
pack_cmd "../Src/obj_setup.sh"

file=arch.make

pack_cmd "echo '# Compilation $(pack_get --version) on $(get_c)' > $file"

pack_cmd "sed -i '$ a\
.SUFFIXES:\n\
.SUFFIXES: .f .F .o .a .f90 .F90\n\
SIESTA_ARCH=x86_64-linux-Intel\n\
\n\
FPP=mpif90\n\
FPP_OUTPUT= \n\
CC=$CC\n\
FC=$MPIF90\n\
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
FPPFLAGS += -DSIESTA__FLOOK \n\
FLOOK_LIB = $(list -LD-rp flook) -lflookall -ldl\n\
LIBS += \$(FLOOK_LIB) \n\
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

# Add LTO in case of gcc-6.1 and above version 4.1
if $(is_c gnu) ; then
    if [[ $(vrs_cmp $(get_c --version) 6.1.0) -ge 0 ]]; then
	pack_cmd "sed -i '$ a\
LIBS += -flto -fuse-linker-plugin \n\
FFLAGS += -flto\n'" arch.make
    fi
fi

pack_set --module-requirement mumps
pack_set --module-requirement fftw-3
pack_cmd "sed -i '$ a\
METIS_LIB = -lmetis\n\
FFTW_PATH = $(pack_get --prefix fftw-3)\n\
FFTW_INCFLAGS = -I\$(FFTW_PATH)/include\n\
FFTW_LIBS = -L\$(FFTW_PATH)/lib -lfftw3 \$(METIS_LIB)\n\
LIBS += \$(METIS_LIB)\n\
FPPFLAGS += -DNCDF -DNCDF_4 -DNCDF_PARALLEL\n\
COMP_LIBS += libncdf.a libfdict.a' $file"

pack_cmd "sed -i '$ a\
FPPFLAGS += -DSIESTA__METIS -DSIESTA__MUMPS -DTS_NOCHECKS\n\
ADDLIB += -lzmumps -lmumps_common -lpord -lparmetis -lmetis' $file"

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

for omp in openmp none ; do
    
    set_flag $omp
    
    # Ensure it is clean...
    pack_cmd "make clean"
    
    # This should ensure a correct handling of the version info...
    pack_cmd "make $(get_make_parallel) siesta"
    pack_cmd "cp siesta $(pack_get --prefix)/bin/siesta$end"
    
    pack_cmd "make clean"
    
    pack_cmd "make $(get_make_parallel) transiesta"
    pack_cmd "cp transiesta $(pack_get --prefix)/bin/transiesta$end"
    
done

pack_cmd "cd ../Util/Bands"
make_files gnubands eigfat2plot fat.gplot

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
    pack_cmd "cp tbtrans $(pack_get --prefix)/bin/tbtrans$end"
    pack_cmd "make clean-tbt ; make $(get_make_parallel) phtrans"
    pack_cmd "cp phtrans $(pack_get --prefix)/bin/phtrans$end"
    pack_cmd "make clean"
    
done
pack_cmd "cd ../TB"
pack_cmd "cp tbt_tb.py tbt_data.py pht_tb.py $(pack_get --prefix)/bin/"
pack_set --module-opt "--prepend-ENV PYTHONPATH=$(pack_get --prefix)/bin"
pack_cmd "cd ../"

# end TS

pack_cmd "cd ../VCA"
make_files mixps fractional

pack_cmd "cd ../Vibra/Src"
make_files fcbuild vibra

pack_cmd "cd ../../WFS"
make_files info_wfsx readwf readwfx wfs2wfsx wfsx2wfs


pack_cmd "cd ../"
pack_cmd "$FC $FCFLAGS vpsa2bin.f -o $(pack_get --prefix)/bin/vpsa2bin"
pack_cmd "$FC $FCFLAGS vpsb2asc.f -o $(pack_get --prefix)/bin/vpsb2asc"

# Compile the 3m equivalent versions, if applicable
pack_cmd "cd ../Obj"
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
	pack_cmd "make clean"
	
	pack_cmd "make $(get_make_parallel) transiesta ; make transiesta"
	pack_cmd "cp transiesta $(pack_get --prefix)/bin/transiesta${end}_3m"

	pack_cmd "pushd ../Util/TS/TBtrans ; make clean"
	pack_cmd "make $(get_make_parallel) ; make"
	pack_cmd "cp tbtrans $(pack_get --prefix)/bin/tbtrans${end}_3m"
	pack_cmd "make clean-tbt ; make $(get_make_parallel) phtrans ; make phtrans"
	pack_cmd "cp phtrans $(pack_get --prefix)/bin/phtrans${end}_3m"
	pack_cmd "make clean"
	pack_cmd "popd"

    done
fi

# Create the byte-compiled versions, to make it faster for users 
tmp=$(pack_get --alias python).$(pack_get --version python)/$(get_c)
pack_cmd "module load $tmp"
pack_cmd "pushd $(pack_get --prefix)/bin/"
pack_cmd "python -m compileall ."
pack_cmd "popd"
pack_cmd "module unload $tmp"


unset set_flag
unset make_files
pack_cmd "chmod a+x $(pack_get --prefix)/bin/*"

done
