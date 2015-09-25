for v in 988 ; do

add_package http://www.student.dtu.dk/~nicpa/packages/siesta-scf-$v.tar.bz2

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/bin/hsx2hs

pack_set --module-requirement mpi --module-requirement netcdf
pack_set --mod-req flook

# Add the lua family
pack_set --module-opt "--lua-family siesta"

# Fix the __FILE__ content in the classes
pack_cmd 'for f in Src/class* Src/fdf/utils.F90 ; do sed -i -e "s:__FILE__:\"$f\":g" $f ; done'
pack_cmd 'sed -i -e "s:__FILE__:Fstack.T90:g" Src/Fstack.T90'

# Change to directory:
pack_cmd "cd Obj"

# Setup the compilation scheme
pack_cmd "../Src/obj_setup.sh"

file=arch.make

# Prepare the compilation $file
pack_cmd "echo '# Compilation $(pack_get --version) on $(get_c)' > $file"
pack_cmd "echo 'PP = cpp -E -P -C -nostdinc' >> $file"

if [[ $(vrs_cmp $v 590) -ge 0 ]]; then
    pack_set --module-requirement mumps
    if [[ $(vrs_cmp $v 662) -ge 0 ]]; then
	pack_set --module-requirement fftw-3
	pack_cmd "sed -i '1 a\
METIS_LIB = -lmetis\n\
FFTW_PATH = $(pack_get --prefix fftw-3)\n\
FFTW_INCFLAGS = -I\$(FFTW_PATH)/include\n\
FFTW_LIBS = -L\$(FFTW_PATH)/lib -lfftw3 \$(METIS_LIB)\n\
LIBS += \$(METIS_LIB)\n\
FPPFLAGS += -DNCDF -DNCDF_4\n\
COMP_LIBS += libncdf.a libvardict.a' $file"
    fi
    pack_cmd "sed -i '1 a\
FPPFLAGS += -DON_DOMAIN_DECOMP -DSIESTA__MUMPS -DTS_NOCHECKS\n\
ADDLIB += -lzmumps -lmumps_common -lpord -lparmetis -lmetis' $file"
else
    if [[ $(pack_installed metis) -eq 1 ]]; then
	pack_set --module-requirement metis
    pack_cmd "sed -i '1 a\
FPPFLAGS += -DON_DOMAIN_DECOMP\n\
ADDLIB += -lmetis' $file"
    fi
fi

pack_cmd "sed -i '1 a\
.SUFFIXES:\n\
.SUFFIXES: .f .F .f90 .F90 .c .o .a\n\
SIESTA_ARCH=x86_64-linux-$(get_c)\n\
\n\
FPP=mpif90\n\
FPP_OUTPUT= \n\
FC=$MPIF90\n\
FC_SERIAL=$FC\n\
CC=$MPICC\n\
CC_SERIAL=$CC\n\
AR=$AR\n\
RANLIB=ranlib\n\
SYS=nag\n\
SP_KIND=4\n\
DP_KIND=8\n\
KINDS=\$(SP_KIND) \$(DP_KIND)\n\
\n\
FFLAGS=$FCFLAGS\n\
FFLAGS += #OMPPLACEHOLDER\n\
FPPFLAGS += -DMPI -DFC_HAVE_FLUSH -DFC_HAVE_ABORT -DCDF -DCDF4 \n\
FPPFLAGS += -DSIESTA__FLOOK \n\
FLOOK_LIB = $(list -LD-rp flook) -lflookall -ldl\n\
LIBS += \$(FLOOK_LIB) \n\
\n\
ARFLAGS_EXTRA=\n\
\n\
NETCDF_INCFLAGS=$(list --INCDIRS netcdf)\n\
NETCDF_LIBS=$(list --LD-rp netcdf)\n\
ADDLIB=-lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz\n\
ADDLIB += #OMPPLACEHOLDER\n\
INCFLAGS = $(list --INCDIRS $(pack_get --mod-req))\n\
\n\
MPI_INTERFACE=libmpi_f90.a\n\
MPI_INCLUDE=.\n\
\n\
' $file"

source applications/siesta-linalg.bash

pack_cmd "mkdir -p $(pack_get --prefix)/bin"

function set_flag {
    local v=$1 ; shift
    end=
    case $v in
	openmp)
	    pack_cmd "sed -i -e 's/\(\#OMPPLACEHOLDER\)/$FLAG_OMP \1/g' $file"
	    pack_cmd "sed -i -e 's:-lzmumps :-lzmumps_omp :g' $file"
	    pack_cmd "sed -i -e 's:-lmumps_common :-lmumps_common_omp :g' $file"

	    end=_omp
	    if [[ "x$siesta_la" == "xopenblas" ]]; then
		pack_cmd "sed -i -e 's:-lopenblas :-lopenblas_omp :g' $file"
	    elif [[ "x$siesta_la" == "xmkl" ]]; then
		pack_cmd "sed -i -e 's:-lmkl_sequential:-lmkl_intel_thread:g' $file"
	    fi
	    ;;
	*)
	    pack_cmd "sed -i -e 's/$FLAG_OMP.*/\#OMPPLACEHOLDER/g' $file"
	    pack_cmd "sed -i -e 's:-l\(zmumps\)[^ ]* :-l\1 :g' $file"
	    pack_cmd "sed -i -e 's:-l\(mumps_common\)[^ ]* :-l\1 :g' $file"

	    end=
	    if [[ "x$siesta_la" == "xopenblas" ]]; then
		pack_cmd "sed -i -e 's:-lopenblas_omp :-lopenblas :g' $file"
	    elif [[ "x$siesta_la" == "xmkl" ]]; then
		pack_cmd "sed -i -e 's:-lmkl_intel_thread:-lmkl_sequential:g' $file"
	    fi
	    ;;
    esac
}

# This should ensure a correct handling of the version info...
if [[ $(vrs_cmp $v 696) -ge 0 ]]; then
    pack_cmd "siesta_install -v scf-l --siesta"
elif [[ $(vrs_cmp $v 662) -ge 0 ]]; then
    pack_cmd "siesta_install -v scf-p --siesta"
else
    pack_cmd "siesta_install -v scf --siesta"
fi

function make_files {
    while [ $# -gt 0 ]; do
	local v=$1 ; shift
	pack_cmd "make $v"
	pack_cmd "cp $v $(pack_get --prefix)/bin/"
    done
}


for omp in openmp none ; do
if [[ $omp == "openmp" ]]; then
if [[ $(vrs_cmp $v 688) -lt 0 ]]; then
    continue
fi
if $(is_c intel) ; then
    continue
fi
fi
set_flag $omp

pack_cmd "make clean"

# This should ensure a correct handling of the version info...
if [[ $(vrs_cmp $v 772) -ge 0 ]]; then
    pack_cmd "make $(get_make_parallel) siesta"
elif [[ $(vrs_cmp $v 662) -ge 0 ]]; then
    source applications/siesta-speed.bash libSiestaXC.a libvardict.a libncdf.a siesta
else
    source applications/siesta-speed.bash libSiestaXC.a siesta
fi
pack_cmd "cp siesta $(pack_get --prefix)/bin/siesta$end"

pack_cmd "make clean"

if [[ $(vrs_cmp $v 772) -ge 0 ]]; then
    pack_cmd "make $(get_make_parallel) transiesta ; make transiesta"
elif [[ $(vrs_cmp $v 662) -ge 0 ]]; then
    source applications/siesta-speed.bash libSiestaXC.a libvardict.a libncdf.a transiesta
else
    source applications/siesta-speed.bash libSiestaXC.a transiesta
fi
pack_cmd "cp transiesta $(pack_get --prefix)/bin/transiesta$end"

done

pack_cmd "cd ../Util/Bands"
make_files new.gnubands eigfat2plot fat.gplot gnubands

pack_cmd "cd ../Contrib/APostnikov"
pack_cmd "make all"
pack_cmd "cp *xsf fmpdos $(pack_get --prefix)/bin/"

if [[ $(vrs_cmp $v 662) -ge 0 ]]; then
    pack_cmd "cd ../../Denchar/Src"
    make_files denchar
fi

pack_cmd "cd ../../Eig2DOS"
make_files Eig2DOS

if [[ $(vrs_cmp $v 862) -ge 0 ]]; then
    pack_cmd "cd ../COOP"
    make_files mprop fat

    pack_cmd "cd ../SpPivot"
    #make_files pvtsp
fi

pack_cmd "cd ../WFS"
make_files info_wfsx readwf readwfx wfs2wfsx wfsx2wfs

# install simple-stm
pack_cmd "cd ../STM/simple-stm"
make_files plstm
if [[ $(vrs_cmp $v 662) -ge 0 ]]; then
    pack_cmd "cd ../ol-stm/Src"
    make_files stm
    pack_cmd "cd .."
fi

pack_cmd "cd ../../HSX"
make_files hs2hsx hsx2hs

# Install the Grimme creator
pack_cmd "cd ../Grimme/"
make_files fdf2grimme

# install the optimizer functions
pack_cmd "cd ../Optimizer"
make_files swarm simplex

# install grid-relevant utilities
# Installing the CDF ones requires that we change the libraries (non-MPI)
pack_cmd "cd ../Grid"
#make_files grid2cdf cdf2xsf cdf2grid cdf_fft cdf_diff
make_files grid2val grid2cube grid_rotate grid_supercell

pack_cmd "cd ../Vibra/Src"
make_files fcbuild vibra

# Install the TS-analyzer
pack_cmd "cd ../../TS/"
pack_cmd "cp tselecs.sh $(pack_get --prefix)/bin/"

if [[ $(vrs_cmp $v 587) -ge 0 ]]; then
    pack_cmd "cd ts2ts"
    make_files ts2ts
fi
if [[ $(vrs_cmp $v 602) -ge 0 ]]; then
    # we need serial netcdf library to compile tshs2tshs :(
    pack_cmd "cd ../tshs2tshs/"
    make_files tshs2tshs
fi
if [[ $(vrs_cmp $v 662) -ge 0 ]]; then
    pack_cmd "cd ../TBtrans/"
    for omp in openmp none ; do

	pack_cmd "pushd ../../../Obj"
	set_flag $omp
	pack_cmd "popd ; make clean"
	if [[ $(vrs_cmp $v 772) -ge 0 ]]; then
	    pack_cmd "make $(get_make_parallel) ; make"
	else
	    pack_cmd "make"
	fi
	pack_cmd "make" # corrects version 
	pack_cmd "cp tbtrans $(pack_get --prefix)/bin/tbtrans$end"
	if [[ $(vrs_cmp $v 772) -ge 0 ]]; then
	    pack_cmd "make clean-tbt ; make $(get_make_parallel) phtrans"
	    pack_cmd "make phtrans" # corrects version 
	    pack_cmd "cp phtrans $(pack_get --prefix)/bin/phtrans$end"
	    pack_cmd "make clean"
	fi
    done
    if [[ $(vrs_cmp $v 750) -lt 0 ]]; then
	pack_cmd "cp tbt_data.py $(pack_get --prefix)/bin/"
    fi
fi
if [[ $(vrs_cmp $v 681) -ge 0 ]]; then
    pack_cmd "cd ../TB/"
    if [[ $(vrs_cmp $v 767) -ge 0 ]]; then
	pack_cmd "cp tbt_tb.py tbt_data.py pht_tb.py $(pack_get --prefix)/bin/"
    else
	pack_cmd "cp tbt_tb.py $(pack_get --prefix)/bin/"
    fi

    pack_set --module-opt "--prepend-ENV PYTHONPATH=$(pack_get --prefix)/bin"
fi

pack_cmd "cd ../../"

pack_cmd "$FC $FCFLAGS vpsa2bin.f -o $(pack_get --prefix)/bin/vpsa2bin"
pack_cmd "$FC $FCFLAGS vpsb2asc.f -o $(pack_get --prefix)/bin/vpsb2asc"

# The atom program for creating the pseudos
pack_cmd "cd ../Pseudo/atom"
make_files atm

pack_cmd "cd ../../Obj"

# Compile the 3m equivalent versions, if applicable
tmp=0
if $(is_c intel) ; then
    tmp=1

elif $(is_c gnu) ; then
    for la in $(choice linalg) ; do
	if [[ $(pack_installed $la) -eq 1 ]]; then
	    if [[ "x$la" == "xopenblas" ]]; then
		# Only openblas has gemm3m
		tmp=1
	    fi
	    break
	fi
    done
fi


if [[ $tmp -eq 1 ]]; then
if [[ $(vrs_cmp $v 662) -ge 0 ]]; then
    # Go back
    pack_cmd "echo '' >> $file ; echo 'FPPFLAGS += -DUSE_GEMM3M' >> $file"
    for omp in openmp none ; do
	if [[ $omp == "openmp" ]]; then
	    if $(is_c intel) ; then
		continue
	    fi
	fi

	set_flag $omp
	pack_cmd "make clean"
	
	if [[ $(vrs_cmp $v 772) -ge 0 ]]; then
	    pack_cmd "make $(get_make_parallel) transiesta ; make transiesta"
	else
	    source applications/siesta-speed.bash libSiestaXC.a libvardict.a libncdf.a transiesta
	fi
	pack_cmd "cp transiesta $(pack_get --prefix)/bin/transiesta${end}_3m"

	pack_cmd "pushd ../Util/TS/TBtrans ; make clean"
	if [[ $(vrs_cmp $v 772) -ge 0 ]]; then
	    pack_cmd "make $(get_make_parallel) ; make"
	else
	    pack_cmd "make"
	fi
	pack_cmd "cp tbtrans $(pack_get --prefix)/bin/tbtrans${end}_3m"
	if [[ $(vrs_cmp $v 772) -ge 0 ]]; then
	    pack_cmd "make clean-tbt ; make $(get_make_parallel) phtrans ; make phtrans"
	    pack_cmd "cp phtrans $(pack_get --prefix)/bin/phtrans${end}_3m"
	    pack_cmd "make clean"
	fi
	pack_cmd "popd"

    done
fi
fi
unset set_flag
unset make_files
pack_cmd "chmod a+x $(pack_get --prefix)/bin/*"

# Create the byte-compiled versions, to make it faster for users 
tmp=$(pack_get --alias python).$(pack_get --version python)/$(get_c)
pack_cmd "module load $tmp"
pack_cmd "pushd $(pack_get --prefix)/bin/"
pack_cmd "python -m compileall ."
pack_cmd "popd"
pack_cmd "module unload $tmp"

# Save the $file file
pack_cmd "cp $file ../../$(get_c).make"

done
