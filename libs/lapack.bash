v=1739
add_package --package lapack http://www.student.dtu.dk/~nicpa/packages/lapack-$v.tar.bz2

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --LD)/liblapack.a

# Prepare the make file
file=make.inc
tmp="sed -i -e"
pack_cmd "cp $file.example $file"
pack_cmd "$tmp 's;FORTRAN[[:space:]]*=.*;FORTRAN = $FC;g' $file"
pack_cmd "$tmp 's;CC[[:space:]]*=.*;CC = $CC;g' $file"
pack_cmd "$tmp 's;ARCH[[:space:]]*=.*;ARCH = $AR;g' $file"
if $(is_c gnu) ; then
    pack_cmd "$tmp 's;OPTS[[:space:]]*=.*;OPTS = $FCFLAGS -frecursive;g' $file"
else
    pack_cmd "$tmp 's;OPTS[[:space:]]*=.*;OPTS = $FCFLAGS;g' $file"
fi 
pack_cmd "$tmp 's;CFLAGS[[:space:]]*=.*;CFLAGS = $CFLAGS;g' $file"
if $(is_c gnu) ; then
    pack_cmd "$tmp 's;NOOPT[[:space:]]*=.*;NOOPT = -fPIC -frecursive;g' $file"
else
    pack_cmd "$tmp 's;NOOPT[[:space:]]*=.*;NOOPT = -fPIC;g' $file"
fi
pack_cmd "$tmp 's;LOADER[[:space:]]*=.*;LOADER = $FC;g' $file"
pack_cmd "$tmp 's;LOADOPTS[[:space:]]*=.*;LOADOPTS = $FCFLAGS;g' $file"
pack_cmd "$tmp 's;TIMER[[:space:]]*=.*;TIMER = INT_CPU_TIME;g' $file"
pack_cmd "$tmp 's;_LINUX;;g' $file"
pack_cmd "$tmp 's;_SUN4;;g' $file"
pack_cmd "$tmp 's?BLASLIB[[:space:]]*=.*?BLASLIB = $(list --LD-rp blas) -lblas?g' $file"
pack_cmd "echo '' >> $file"
pack_cmd "echo 'LAPACKE_WITH_TMG = Yes' >> $file"

# Make commands
pack_cmd "make $(get_make_parallel) lapacklib lapackelib tmglib"

pack_cmd "mkdir -p $(pack_get --LD)"
pack_cmd "mkdir -p $(pack_get --prefix)/include/"
pack_cmd "cp liblapack.a liblapacke.a $(pack_get --LD)/"
pack_cmd "cp libtmglib.a $(pack_get --LD)/libtmg.a"
pack_cmd "cp LAPACKE/include/*.h $(pack_get --prefix)/include/"

add_hidden_package lapack-blas/$v
# Denote the default libraries
pack_set --installed $_I_REQ
pack_set -mod-req blas
pack_set -mod-req lapack
pack_set -lib -llapack -lblas
pack_set -lib[omp] -llapack $(pack_get -lib[omp] blas)
pack_set -lib[pt] -llapack $(pack_get -lib[pt] blas)
pack_set -lib[lapacke] -llapacke

