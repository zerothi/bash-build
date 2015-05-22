add_package http://garr.dl.sourceforge.net/project/elk/elk-3.0.18.tgz

pack_set --host-reject ntch --host-reject zeroth

pack_set --install-query $(pack_get --prefix)/bin/elk

pack_set --module-requirement mpi \
    --module-requirement libxc \
    --module-requirement fftw-3

# Add the lua family
pack_set --module-opt "--lua-family elk"

if test -z "$FLAG_OMP" ; then
    doerr elk "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi

tmp=
if $(is_c intel) ; then
    tmp=" $MKL_LIB -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -mkl=parallel"
fi

file=make.inc
# Prepare the compilation arch.make
pack_set --command "echo '# Compilation $(pack_get --version) on $(get_c)' > $file"
pack_set --command "sed -i '1 a\
MAKE = make\n\
F90 = $MPIF90\n\
F90_OPTS = $FCFLAGS $FLAG_OMP $tmp \n\
F77 = $MPIF77\n\
F77_OPTS = $FCFLAGS $FLAG_OMP $tmp \n\
AR = $AR \n\
LIB_libxc = $(list --LD-rp mpi libxc) -lxcf90 -lxc\n\
SRC_libxc = libxc_funcs.f90 libxc.f90 libxcifc.f90\n\
LIB_FFT = $(list --LD-rp fftw-3) -lfftw3\n\
SRC_FFT = zfftifc.f90\n\
' $file"

tmp=
# Check for Intel MKL or not
if $(is_c intel) ; then
    pack_set --command "sed -i '1 a\
LIB_LPK = $tmp\n\
' $file"

elif $(is_c gnu) ; then

    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ] ; then
	    pack_set --module-requirement $la
	    tmp="-llapack"
	    if [ "x$la" == "xatlas" ]; then
		tmp="$tmp -lf77blas -lcblas -latlas"
	    elif [ "x$la" == "xopenblas" ]; then
		tmp="$tmp -lopenblas_omp"
	    elif [ "x$la" == "xblas" ]; then
		tmp="$tmp -lblas"
	    fi
	    break
	fi
    done

    pack_set --command "sed -i '1 a\
LIB_LPK = $(list --LD-rp $(pack_get --mod-req)) $tmp\n\
' $file"

else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi

# Create the correct file for the interface to FFTW
file=src/zfftifc.f90
pack_set --command "echo '! FFTW routine' > $file"
pack_set --command "sed -i 'a\
subroutine zfftifc(nd,n,sgn,z)\n\
implicit none\n\
integer, intent(in) :: nd, n(nd), sgn\n\
complex(8), intent(inout) :: z(*)\n\
integer, parameter :: FFTW_ESTIMATE=64\n\
integer i,p\n\
integer(8) plan\n\
real(8) t1\n\
!\$OMP CRITICAL\n\
call dfftw_plan_dft(plan,nd,n,z,z,sgn,FFTW_ESTIMATE)\n\
!\$OMP END CRITICAL\n\
call dfftw_execute(plan)\n\
!\$OMP CRITICAL\n\
call dfftw_destroy_plan(plan)\n\
!\$OMP END CRITICAL\n\
if (sgn.eq.-1) then\n\
  p=1\n\
  do i=1,nd\n\
    p=p*n(i)\n\
  end do\n\
  t1=1.d0/dble(p)\n\
  call zdscal(p,t1,z,1)\n\
end if\n\
end subroutine\n\
' $file"

pack_set --command "make $(get_make_parallel)"

pack_set --command "mkdir -p $(pack_get --prefix)/bin"
pack_set --command "cp src/protex src/elk $(pack_get --prefix)/bin/"
pack_set --command "cp src/spacegroup/spacegroup $(pack_get --prefix)/bin/"
pack_set --command "cp src/eos/eos $(pack_get --prefix)/bin/"
pack_set --command "cp utilities/blocks2columns/blocks2columns.py $(pack_get --prefix)/bin/"
pack_set --command "cp utilities/elk-bands/elk-bands $(pack_get --prefix)/bin/"
pack_set --command "cp utilities/wien2k-elk/se.pl $(pack_get --prefix)/bin/"
pack_set --command "chmod a+x $(pack_get --prefix)/bin/*"

# Create the species input
pack_set --command "cp -rf species $(pack_get --prefix)/species"
pack_set --module-opt "--set-ENV ELK_SPECIES=$(pack_get --prefix)/species"


pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --mod-req)) \
    -L $(pack_get --alias)
