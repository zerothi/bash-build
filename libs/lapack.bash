v=3.11.0
add_package --version $v --archive lapack-$v.tar.gz https://github.com/Reference-LAPACK/lapack/archive/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/liblapack.a
pack_set -lib -llapack
pack_set -lib[omp] -llapack
pack_set -lib[pt] -llapack

# Prepare the make file
file=make.inc
tmp="sed -i -e"
pack_cmd "cp $file.example $file"
# In 3.8.0 we still use the older names

pack_cmd "$tmp 's;FC[[:space:]]*=.*;FC = $FC;g' $file"
pack_cmd "$tmp 's;FORTRAN[[:space:]]*=.*;FORTRAN = $FC;g' $file"
pack_cmd "$tmp 's;CC[[:space:]]*=.*;CC = $CC;g' $file"
pack_cmd "$tmp 's;AR[[:space:]]*=.*;AR = $AR;g' $file"
pack_cmd "$tmp 's;ARCH[[:space:]]*=.*;ARCH = $AR;g' $file"
pack_cmd "$tmp 's;RANLIB[[:space:]]*=.*;RANLIB = $RANLIB;g' $file"
if $(is_c gnu-unsafe) ; then
    pack_cmd "$tmp 's;FFLAGS[[:space:]]*=.*;FFLAGS = ${FFLAGS//-Ofast/-O3} -frecursive;g' $file"
    pack_cmd "$tmp 's;OPTS[[:space:]]*=.*;OPTS = ${FFLAGS//-Ofast/-O3} -frecursive;g' $file"
elif $(is_c gnu) ; then
    pack_cmd "$tmp 's;FFLAGS[[:space:]]*=.*;FFLAGS = $FFLAGS -frecursive;g' $file"
    pack_cmd "$tmp 's;OPTS[[:space:]]*=.*;OPTS = $FFLAGS -frecursive;g' $file"
elif $(is_c intel-unsafe) ; then
    pack_cmd "$tmp 's;FFLAGS[[:space:]]*=.*;FFLAGS = ${FFLAGS//-Ofast/-O3};g' $file"
    pack_cmd "$tmp 's;OPTS[[:space:]]*=.*;OPTS = ${FFLAGS//-Ofast/-O3};g' $file"
else
    pack_cmd "$tmp 's;FFLAGS[[:space:]]*=.*;FFLAGS = $FFLAGS;g' $file"
    pack_cmd "$tmp 's;OPTS[[:space:]]*=.*;OPTS = $FFLAGS;g' $file"
fi 
if $(is_c gnu-unsafe) ; then
    pack_cmd "$tmp 's;CFLAGS[[:space:]]*=.*;CFLAGS = ${CFLAGS//-Ofast/-O3};g' $file"
elif $(is_c intel-unsafe) ; then
    pack_cmd "$tmp 's;CFLAGS[[:space:]]*=.*;CFLAGS = ${CFLAGS//-Ofast/-O3};g' $file"
else
    pack_cmd "$tmp 's;CFLAGS[[:space:]]*=.*;CFLAGS = $CFLAGS;g' $file"
fi
if $(is_c gnu) ; then
    pack_cmd "$tmp 's;FFLAGS_NOOPT[[:space:]]*=.*;FFLAGS_NOOPT = -fPIC -frecursive;g' $file"
    pack_cmd "$tmp 's;NOOPT[[:space:]]*=.*;NOOPT = -fPIC -frecursive;g' $file"
else
    pack_cmd "$tmp 's;FFLAGS_NOOPT[[:space:]]*=.*;FFLAGS_NOOPT = -fPIC;g' $file"
    pack_cmd "$tmp 's;NOOPT[[:space:]]*=.*;NOOPT = -fPIC;g' $file"
fi
pack_cmd "echo '' >> $file"
pack_cmd "echo 'BUILD_DEPRECATED = Yes' >> $file"
pack_cmd "echo 'LAPACKE_WITH_TMG = Yes' >> $file"
pack_cmd "echo 'LDFLAGS += \$(FFLAGS) \$(OPTS)' >> $file"
pack_cmd "echo 'LOADOPTS += \$(FFLAGS) \$(OPTS)' >> $file"
pack_cmd "echo 'TIMER = INT_CPU_TIME' >> $file"

# Make commands
pack_cmd "make $(get_make_parallel) blaslib cblaslib"
pack_cmd "make $(get_make_parallel) lapacklib lapackelib tmglib"

# Make test commands
pack_cmd "make blas_testing 2>&1 > blas.test"
pack_cmd "make cblas_testing 2>&1 > cblas.test"
if $(is_c intel) ; then
    pack_cmd "make lapack_testing 2>&1 > lapack.test || echo forced"
else
    pack_cmd "make lapack_testing 2>&1 > lapack.test"
fi
pack_store lapack.test
pack_store blas.test
pack_store cblas.test
pack_cmd "pushd TESTING"
pack_cmd "for f in *.out ; do mv \$f $(pack_get -prefix)/ ; done"
pack_cmd "popd"

# Installation commands
pack_cmd "mkdir -p $(pack_get --LD)"
pack_cmd "mkdir -p $(pack_get --prefix)/include/"
pack_cmd "cp libcblas.a $(pack_get --LD)/"
pack_cmd "cp librefblas.a $(pack_get --LD)/libblas.a"
pack_cmd "cp liblapack.a liblapacke.a $(pack_get --LD)/"
pack_cmd "cp libtmglib.a $(pack_get --LD)/libtmg.a"
# Install header-files
pack_cmd "cp CBLAS/include/*.h $(pack_get -prefix)/include/"
pack_cmd "cp LAPACKE/include/*.h $(pack_get -prefix)/include/"
pack_cmd "cd $(pack_get -prefix)"
pack_cmd 'for f in *.out ; do gzip $f ; done'



add_hidden_package blas/$v
pack_set --prefix $(pack_get --prefix lapack)
# Denote the default libraries
pack_set --installed $_I_REQ
pack_set -lib -lblas
pack_set -lib[omp] -lblas
pack_set -lib[pt] -lblas

add_hidden_package cblas/$v
pack_set --prefix $(pack_get --prefix lapack)
pack_set --installed $_I_REQ
pack_set -lib -lcblas -lblas
pack_set -lib[omp] -lcblas -lblas
pack_set -lib[pt] -lcblas -lblas

add_hidden_package lapack-blas/$v
pack_set --prefix $(pack_get --prefix lapack)
pack_set --installed $_I_REQ
pack_set -mod-req lapack
pack_set -lib -llapack -lblas
pack_set -lib[omp] -llapack -lblas
pack_set -lib[pt] -llapack -lblas
pack_set -lib[lapacke] -llapacke

