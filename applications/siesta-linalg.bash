# Generic routine for adding linear algebra
# libraries to siesta

# SIESTA also enables ELPA kernel
pack_set -module-requirement elpa

# Check for Intel MKL or not
siesta_la=mkl
if $(is_c intel) ; then

#    pack_cmd "sed -i '$ a\
#LIBS +=$MKL_LIB $(list -LD-rp $(pack_get -mod-req-path))\n' arch.make"
    case $_mpi_version in
	openmpi)
	    pack_cmd "sed -i '$ a\
SCALAPACK_LIBS = $MKL_LIB -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64\n\
LAPACK_LIBS = $MKL_LIB -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential\n' arch.make"
	    ;;
	mpich)
	    pack_cmd "sed -i '$ a\
SCALAPACK_LIBS = $MKL_LIB -lmkl_scalapack_lp64 -lmkl_blacs_intelmpi_lp64\n\
LAPACK_LIBS = $MKL_LIB -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential\n' arch.make"
	    ;;
    esac
    pack_cmd "sed -i '$ a\
	    LIBS += \$(SCALAPACK_LIBS) \$(LAPACK_LIBS)\n' arch.make"

# If one ever needs MKL with gnu compiler it should be -lmkl_gf_lp64 instead of -lmkl_intel_lp64

elif $(is_c gnu) ; then
    
    pack_set -module-requirement scalapack
    siesta_la=$(pack_choice -i linalg)
    la=lapack-$siesta_la
    pack_set -module-requirement $la
    pack_cmd "sed -i '$ a\
LIBS += $(list -LD-rp $(pack_get -mod-req-path))\n\
SCALAPACK_LIBS = -lscalapack\n\
LAPACK_LIBS = $(pack_get -lib $la)\n\
LIBS += \$(SCALAPACK_LIBS) \$(LAPACK_LIBS)\n' arch.make"

else
    doerr "$(pack_get -package)" "Could not recognize the compiler: $(get_c)"

fi

# Add the MRRR libraries (we know they always have MRRR)
pack_cmd "sed -i '$ a\
WITH_EXTRA_FPPFLAGS += SIESTA__MRRR\n' arch.make"

pack_cmd "[ -e ../Src/atom.F ] && sed -i '$ a\
atom.o: atom.F\n\
\t\$(FC) -c -O1 \$(INCFLAGS) \$(FPPFLAGS) \$<\n' arch.make || echo NVM"
pack_cmd "[ -e ../Src/atom.f ] && sed -i '$ a\
atom.o: atom.f\n\
\t\$(FC) -c -O1 \$(INCFLAGS) \$<\n' arch.make || echo NVM"

if $(is_c intel) ; then
    # Threading and m_new_dm does not work
    # Besides it is so little a routine that we simply compile it with
    # lower optimization
    pack_cmd "sed -i '$ a\
m_new_dm.o: m_new_dm.F90\n\
\t\$(FC) -c -O2 \$(INCFLAGS) \$(FPPFLAGS) \$<\n' arch.make || echo NVM"
fi
