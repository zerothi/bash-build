# Then install LAPACK
bl=$1
shift

add_package --package lapack-$bl http://www.student.dtu.dk/~nicpa/packages/lapack-1545.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --LD $bl)/liblapack.a

pack_set --module-requirement $bl

# Prepare the make file
file=make.inc
tmp="sed -i -e"
pack_set --command "cp $file.example $file"
pack_set --command "$tmp 's;FORTRAN[[:space:]]*=.*;FORTRAN = $FC;g' $file"
pack_set --command "$tmp 's;CC[[:space:]]*=.*;CC = $CC;g' $file"
pack_set --command "$tmp 's;ARCH[[:space:]]*=.*;ARCH = $AR;g' $file"
if $(is_c gnu) ; then
    pack_set --command "$tmp 's;OPTS[[:space:]]*=.*;OPTS = $FCFLAGS -frecursive;g' $file"
else
    pack_set --command "$tmp 's;OPTS[[:space:]]*=.*;OPTS = $FCFLAGS;g' $file"
fi 
pack_set --command "$tmp 's;CFLAGS[[:space:]]*=.*;CFLAGS = $CFLAGS;g' $file"
if $(is_c gnu) ; then
    pack_set --command "$tmp 's;NOOPT[[:space:]]*=.*;NOOPT = -fPIC -frecursive;g' $file"
else
    pack_set --command "$tmp 's;NOOPT[[:space:]]*=.*;NOOPT = -fPIC;g' $file"
fi
pack_set --command "$tmp 's;LOADER[[:space:]]*=.*;LOADER = $FC;g' $file"
pack_set --command "$tmp 's;LOADOPTS[[:space:]]*=.*;LOADOPTS = $FCFLAGS;g' $file"
pack_set --command "$tmp 's;TIMER[[:space:]]*=.*;TIMER = INT_CPU_TIME;g' $file"
pack_set --command "$tmp 's;_LINUX;;g' $file"
pack_set --command "$tmp 's;_SUN4;;g' $file"
if [ $bl == "blas" ]; then
    pack_set --command "$tmp 's?BLASLIB[[:space:]]*=.*?BLASLIB = $(list --LD-rp $bl) -lblas?g' $file"
elif [ $bl == "atlas" ]; then
    pack_set --command "$tmp 's?BLASLIB[[:space:]]*=.*?BLASLIB = $(list --LD-rp $bl) -lf77blas -lcblas -latlas?g' $file"
elif [ $bl == "openblas" ]; then
    pack_set --command "$tmp 's?BLASLIB[[:space:]]*=.*?BLASLIB = $(list --LD-rp $bl) -lopenblas?g' $file"
fi
pack_set --command "echo '' >> $file"
pack_set --command "echo 'LAPACKE_WITH_TMG = Yes' >> $file"

# Make commands
pack_set --command "make $(get_make_parallel) lapacklib lapackelib tmglib"

pack_set --command "cp liblapack.a liblapacke.a $(pack_get --LD $bl)/"
pack_set --command "cp libtmglib.a $(pack_get --LD $bl)/libtmg.a"
pack_set --command "mkdir -p $(pack_get --prefix $bl)/include/"
pack_set --command "cp LAPACKE/include/*.h $(pack_get --prefix $bl)/include/"

if [ $bl == "atlas" ]; then
    # We need to collect the two sets
    pack_set --command "mkdir -p tmp"
    pack_set --command "cd tmp"
    # Extract atlas optimized lapack routines
    pack_set --command "$AR x $(pack_get --LD $bl)/liblapack_atlas.a"
    # replace them
    pack_set --command "$AR r ../liblapack.a *.o"
    pack_set --command "cd .."
    pack_set --command "ranlib liblapack.a"
    pack_set --command "cp liblapack.a $(pack_get --LD $bl)/liblapack.a"
fi
