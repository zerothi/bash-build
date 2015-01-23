for v in 631 688 699 ; do

add_package http://www.student.dtu.dk/~nicpa/packages/siesta-scf-$v.tar.bz2

pack_set -s $IS_MODULE -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/bin/hsx2hs

pack_set --module-requirement openmpi --module-requirement netcdf

# Add the lua family
pack_set --module-opt "--lua-family siesta"

# Fix the __FILE__ content in the classes
pack_set --command 'for f in Src/class* ; do sed -i -e "s:__FILE__:\"$f\":g" $f ; done'
pack_set --command "sed -i -e 's:__FILE__:Fstack.T90:g' Src/Fstack.T90"

# Change to directory:
pack_set --command "cd Obj"

# Setup the compilation scheme
pack_set --command "../Src/obj_setup.sh"

# Prepare the compilation arch.make
pack_set --command "echo '# Compilation $(pack_get --version) on $(get_c)' > arch.make"

if [ $(vrs_cmp $v 590) -ge 0 ]; then
    pack_set --module-requirement mumps
    if [ $(vrs_cmp $v 662) -ge 0 ]; then
	pack_set --module-requirement fftw-3
	pack_set --command "sed -i '1 a\
METIS_LIB = -lmetis\n\
FFTW_PATH = $(pack_get --prefix fftw-3)\n\
FFTW_INCFLAGS = -I\$(FFTW_PATH)/include\n\
FFTW_LIBS = -L\$(FFTW_PATH)/lib -lfftw3 \$(METIS_LIB)\n\
LIBS += \$(METIS_LIB)\n\
FPPFLAGS += -DNCDF -DNCDF_4\n\
COMP_LIBS += libncdf.a libvardict.a' arch.make"
    fi
    pack_set --command "sed -i '1 a\
FPPFLAGS += -DON_DOMAIN_DECOMP -DMUMPS\n\
ADDLIB += -lzmumps -lmumps_common -lpord -lparmetis -lmetis' arch.make"
else
    if [ $(pack_installed metis) -eq 1 ]; then
	pack_set --module-requirement metis
    pack_set --command "sed -i '1 a\
FPPFLAGS += -DON_DOMAIN_DECOMP\n\
ADDLIB += -lmetis' arch.make"
    fi
fi

pack_set --command "sed -i '1 a\
.SUFFIXES:\n\
.SUFFIXES: .f .F .o .a .f90 .F90\n\
SIESTA_ARCH=x86_64-linux-Intel\n\
\n\
FPP=mpif90\n\
FPP_OUTPUT= \n\
FC=mpif90\n\
FC_SERIAL=$FC\n\
AR=$AR\n\
RANLIB=ranlib\n\
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
NETCDF_LIBS=$(list --LDFLAGS --Wlrpath netcdf)\n\
ADDLIB=-lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz\n\
ADDLIB += #OMPPLACEHOLDER\n\
INCFLAGS = $(list --INCDIRS $(pack_get --mod-req))\n\
\n\
MPI_INTERFACE=libmpi_f90.a\n\
MPI_INCLUDE=.\n\
\n\
.F.o:\n\
\t\$(FC) -c \$(FFLAGS) \$(INCFLAGS) \$(FPPFLAGS) \$< \n\
.F90.o:\n\
\t\$(FC) -c \$(FFLAGS) \$(INCFLAGS) \$(FPPFLAGS) \$< \n\
.f.o:\n\
\t\$(FC) -c \$(FFLAGS) \$(INCFLAGS) \$<\n\
.f90.o:\n\
\t\$(FC) -c \$(FFLAGS) \$(INCFLAGS) \$<\n\
' arch.make"

source applications/siesta-linalg.bash

pack_set --command "mkdir -p $(pack_get --prefix)/bin"

function set_flag {
    local v=$1 ; shift
    end=
    case $v in
	openmp)
	    pack_set --command "sed -i -e 's/\(\#OMPPLACEHOLDER\)/$FLAG_OMP \1/g' arch.make"
	    end=_omp
	    ;;
	*)
	    pack_set --command "sed -i -e 's/$FLAG_OMP.*/\#OMPPLACEHOLDER/g' arch.make"
	    end=
	    ;;
    esac
}

# This should ensure a correct handling of the version info...
if [ $(vrs_cmp $v 696) -ge 0 ]; then
    pack_set --command "siesta_install -v scf-l --siesta"
elif [ $(vrs_cmp $v 662) -ge 0 ]; then
    pack_set --command "siesta_install -v scf-p --siesta"
else
    pack_set --command "siesta_install -v scf --siesta"
fi

for omp in openmp none ; do
set_flag $omp

pack_set --command "make clean"

# This should ensure a correct handling of the version info...
if [ $(vrs_cmp $v 662) -ge 0 ]; then
    source applications/siesta-speed.bash libSiestaXC.a libvardict.a libncdf.a siesta
else
    source applications/siesta-speed.bash libSiestaXC.a siesta
fi
pack_set --command "cp siesta $(pack_get --prefix)/bin/siesta$end"

pack_set --command "make clean"

if [ $(vrs_cmp $v 662) -ge 0 ]; then
    source applications/siesta-speed.bash libSiestaXC.a libvardict.a libncdf.a transiesta
else
    source applications/siesta-speed.bash libSiestaXC.a transiesta
fi
pack_set --command "cp transiesta $(pack_get --prefix)/bin/transiesta$end"

done

pack_set --command "cd ../Util/Bands"
pack_set --command "make all"
pack_set --command "cp new.gnubands eigfat2plot fat.gplot gnubands $(pack_get --prefix)/bin/"

pack_set --command "cd ../Contrib/APostnikov"
pack_set --command "make all"
pack_set --command "cp *xsf fmpdos $(pack_get --prefix)/bin/"

if [ $(vrs_cmp $v 662) -ge 0 ]; then
    pack_set --command "cd ../../Denchar/Src"
    pack_set --command "make denchar"
    pack_set --command "cp denchar $(pack_get --prefix)/bin/"
fi

pack_set --command "cd ../../Eig2DOS"
pack_set --command "make"
pack_set --command "cp Eig2DOS $(pack_get --prefix)/bin/"

pack_set --command "cd ../WFS"
files="info_wfsx readwf readwfx wfs2wfsx wfsx2wfs"
pack_set --command "make $files"
pack_set --command "cp $files $(pack_get --prefix)/bin/"

# install simple-stm
pack_set --command "cd ../STM/simple-stm"
pack_set --command "make"
pack_set --command "cp plstm $(pack_get --prefix)/bin/"
if [ $(vrs_cmp $v 662) -ge 0 ]; then
    pack_set --command "cd ../ol-stm/Src"
    pack_set --command "make"
    pack_set --command "cp stm $(pack_get --prefix)/bin/"
    pack_set --command "cd .."
fi

pack_set --command "cd ../../HSX"
files="hs2hsx hsx2hs"
pack_set --command "make $files"
pack_set --command "cp $files $(pack_get --prefix)/bin/"

# Install the Grimme creator
pack_set --command "cd ../Grimme/"
pack_set --command "make"
pack_set --command "cp fdf2grimme $(pack_get --prefix)/bin/"

# install the optimizer functions
pack_set --command "cd ../Optimizer"
pack_set --command "make swarm simplex"
pack_set --command "cp swarm simplex $(pack_get --prefix)/bin/"

# install grid-relevant utilities
# This requires that we change the libraries
pack_set --command "cd ../Grid"
files="grid2cdf cdf2xsf cdf2grid grid2val grid2cube grid_rotate cdf_fft cdf_diff grid_supercell"
files="grid2val grid2cube grid_rotate grid_supercell"
pack_set --command "make $files"
pack_set --command "cp $files $(pack_get --prefix)/bin/"

pack_set --command "cd ../Vibra/Src"
pack_set --command "make"
pack_set --command "cp fcbuild vibrator $(pack_get --prefix)/bin/"

# Install the TS-analyzer
pack_set --command "cd ../../TS/"
pack_set --command "cp AnalyzeSort/tsanalyzesort.py $(pack_get --prefix)/bin/"
pack_set --command "cp tselecs.sh $(pack_get --prefix)/bin/"

if [ $(vrs_cmp $v 587) -ge 0 ]; then
    pack_set --command "cd ts2ts"
    pack_set --command "make"
    pack_set --command "cp ts2ts $(pack_get --prefix)/bin/"
fi
if [ $(vrs_cmp $v 602) -ge 0 ]; then
    # we need serial netcdf library to compile tshs2tshs :(
    pack_set --command "cd ../tshs2tshs/"
    pack_set --command "make"
    pack_set --command "cp tshs2tshs $(pack_get --prefix)/bin/"
fi
if [ $(vrs_cmp $v 662) -ge 0 ]; then
    pack_set --command "cd ../TBtrans/"
    for omp in openmp none ; do
	pack_set --command "pushd ../../../Obj"
	set_flag $omp
	pack_set --command "popd"
	pack_set --command "make clean ; make"
	pack_set --command "cp tbtrans $(pack_get --prefix)/bin/tbtrans$end"
    done
    pack_set --command "cp tbt_data.py $(pack_get --prefix)/bin/"
fi
if [ $(vrs_cmp $v 681) -ge 0 ]; then
    pack_set --command "cd ../TB/"
    pack_set --command "cp tbt_tb.py $(pack_get --prefix)/bin/"
    pack_set --module-opt "--prepend-ENV PYTHONPATH=$(pack_get --prefix)/bin"
fi

pack_set --command "cd ../../"

pack_set --command "$FC $FCFLAGS vpsa2bin.f -o $(pack_get --prefix)/bin/vpsa2bin"
pack_set --command "$FC $FCFLAGS vpsb2asc.f -o $(pack_get --prefix)/bin/vpsb2asc"

# The atom program for creating the pseudos
pack_set --command "cd ../Pseudo/atom"
pack_set --command "make"
pack_set --command "cp atm $(pack_get --prefix)/bin/"

# Compile the 3m equivalent versions
if $(is_c intel) ; then
if [ $(vrs_cmp $v 662) -ge 0 ]; then
    # Go back
    pack_set --command "cd ../../Obj"
    pack_set --command "echo '' >> arch.make ; echo 'FPPFLAGS += -DUSE_GEMM3M' >> arch.make"
    for omp in openmp none ; do
	set_flag $omp
	pack_set --command "make clean"
	
	source applications/siesta-speed.bash libSiestaXC.a libvardict.a libncdf.a transiesta
	pack_set --command "cp transiesta $(pack_get --prefix)/bin/transiesta${end}_3m"

	pack_set --command "pushd ../Util/TS/TBtrans"
	pack_set --command "make clean ; make"
	pack_set --command "cp tbtrans $(pack_get --prefix)/bin/tbtrans${end}_3m"
	pack_set --command "popd"
    done
fi
fi
unset set_flag
pack_set --command "chmod a+x $(pack_get --prefix)/bin/*"

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --mod-req)) \
    -L $(pack_get --alias)

done
