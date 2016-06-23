v=3.8
add_package --package openmx \
    --version $v.0 \
    http://www.openmx-square.org/openmx$v.tar.gz

pack_set --module-opt "--lua-family openmx"

pack_set --host-reject ntch-l --host-reject zerothi

pack_set --install-query $(pack_get --prefix)/bin/openmx

pack_set --module-requirement mpi --module-requirement fftw-mpi-3

# Move to the source directory
pack_cmd "cd source"

if [[ $(vrs_cmp $v 3.7) -eq 0 ]]; then
    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-patch3.7.10.tar.gz
    dwn_file http://www.openmx-square.org/bugfixed/15Feb21/patch3.7.10.tar.gz $o
    pack_cmd "tar xfz $o"
fi

if [[ -z "$FLAG_OMP" ]]; then
    doerr OpenMX "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi

# Clean up the makefile
file=makefile
pack_cmd "sed -i -e 's/^LIB[^E].*//g;s/^[FC]C[[:space:]]*=.*//g' $file"
pack_cmd "sed -i -e 's/^CFLAGS.*//g;s:^-I/usr/local/include.*::g' $file"
# Ensures that linking gets the FORTRAN files, we could also add -lgfortran
#tools="openmx TranMain esp check_lead polB analysis_example jx DosMain"
#for tool in $tools ; do
#    pack_cmd "sed -i -e '/-o $tool/{s/CC/FC/}' $file"
#done
pack_cmd "sed -i -e '/^DESTDIR*/d' $file"

if $(is_c intel) ; then    
    # Added ifcore library to complie
    pack_cmd "sed -i '1 a\
    LIB += -mkl=parallel -lifcore \nCC += $FLAG_OMP\nFC += $FLAG_OMP -nofor_main' $file"
    
else
    pack_set --module-requirement scalapack

    la=$(pack_choice -i linalg)
    pack_set --module-requirement lapack-$la
    pack_cmd "sed -i '1 a\
LIB += $(list --LD-rp scalapack +$la) -lscalapack $(pack_get -lib[omp] $la)' $file"

    # Add the gfortran library
    pack_cmd "sed -i '1 a\
LIB += -lgfortran' $file"

    pack_cmd "sed -i '1 a\
CC += $FLAG_OMP\nFC += $FLAG_OMP' $file"
    
fi
pack_cmd "sed -i '1 a\
INCS = $(list --INCDIRS $(pack_get --mod-req-path))\n\
DESTDIR = $(pack_get --prefix)/bin\n\
CC = $MPICC $CFLAGS \$(INCS)\n\
FC = $MPIF90 $FFLAGS \$(INCS)\n\
' $file"

# Ensure linking to the fortran libraries
case $_mpi_version in
    mpich)
	pack_cmd "sed -i '1 a\
LIB = $(list --LD-rp $(pack_get --mod-req-path)) -lfftw3_mpi -lfftw3 -lmpifort -lmpi \n' $file"
	;;
    *)
	pack_cmd "sed -i '1 a\
LIB = $(list --LD-rp $(pack_get --mod-req-path)) -lfftw3_mpi -lfftw3 -lmpi_mpifh -lmpi \n' $file"
	;;
esac

# prepare the directory of installation
pack_cmd "mkdir -p $(pack_get --prefix)/bin"

# Make commands
pack_cmd "make"
pack_cmd "make install"
for tool in TranMain esp polB analysis_example jx DosMain ; do
    pack_cmd "make $tool"
done
# Apparently this is the only tool that is not automatically installed
pack_cmd "cp TranMain $(pack_get --prefix)/bin/"

# Add an ENV-flag for the pseudos to be accesible
pack_cmd "cd ../DFT_DATA13"
pack_cmd "cp -r PAO VPS $(pack_get --prefix)/"
pack_set --module-opt "--set-ENV OPENMX_PAO=$(pack_get --prefix)/PAO"
pack_set --module-opt "--set-ENV OPENMX_VPS=$(pack_get --prefix)/VPS"
