# Then install LAPACK
for bl in blas atlas openblas ; do

add_package --package lapack-$bl http://www.netlib.org/lapack/lapack-3.5.0.tgz

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --install-prefix $bl)/lib/liblapack.a

pack_set --module-requirement $bl

# Prepare the make file
file=make.inc
tmp="sed -i -e"
pack_set --command "cp $file.example $file"
pack_set --command "$tmp 's/FORTRAN[[:space:]]*=.*/FORTRAN = $FC/g' $file"
pack_set --command "$tmp 's/CC[[:space:]]*=.*/CC = $CC/g' $file"
pack_set --command "$tmp 's/ARCH[[:space:]]*=.*/ARCH = $AR/g' $file"
if $(is_c gnu) ; then
    pack_set --command "$tmp 's/OPTS[[:space:]]*=.*/OPTS = $FCFLAGS -frecursive/g' $file"
else
    pack_set --command "$tmp 's/OPTS[[:space:]]*=.*/OPTS = $FCFLAGS/g' $file"
fi 
pack_set --command "$tmp 's/CFLAGS[[:space:]]*=.*/CFLAGS = $CFLAGS/g' $file"
if $(is_c gnu) ; then
    pack_set --command "$tmp 's/NOOPT[[:space:]]*=.*/NOOPT = -fPIC -frecursive/g' $file"
else
    pack_set --command "$tmp 's/NOOPT[[:space:]]*=.*/NOOPT = -fPIC/g' $file"
fi
pack_set --command "$tmp 's/LOADER[[:space:]]*=.*/LOADER = $FC/g' $file"
pack_set --command "$tmp 's/LOADOPTS[[:space:]]*=.*/LOADOPTS = $FCFLAGS/g' $file"
pack_set --command "$tmp 's/TIMER[[:space:]]*=.*/TIMER = INT_CPU_TIME/g' $file"
pack_set --command "$tmp 's/_LINUX//g' $file"
pack_set --command "$tmp 's/_SUN4//g' $file"
if [ $bl == "blas" ]; then
pack_set --command "$tmp 's?BLASLIB[[:space:]]*=.*?BLASLIB = $(list --Wlrpath --LDFLAGS $bl) -lblas?g' $file"
elif [ $bl == "atlas" ]; then
pack_set --command "$tmp 's?BLASLIB[[:space:]]*=.*?BLASLIB = $(list --Wlrpath --LDFLAGS $bl) -lf77blas -lcblas -latlas?g' $file"
elif [ $bl == "openblas" ]; then
pack_set --command "$tmp 's?BLASLIB[[:space:]]*=.*?BLASLIB = $(list --Wlrpath --LDFLAGS $bl) -lopenblas?g' $file"
fi
pack_set --command "echo '' >> $file"
pack_set --command "echo 'LAPACKE_WITH_TMG = Yes' >> $file"

# Make commands
pack_set --command "make $(get_make_parallel) lapacklib lapackelib tmglib"

pack_set --command "cp liblapack.a liblapacke.a $(pack_get --install-prefix $bl)/lib/"
pack_set --command "cp libtmglib.a $(pack_get --install-prefix $bl)/lib/libtmg.a"
pack_set --command "mkdir -p $(pack_get --install-prefix $bl)/include/"
pack_set --command "cp lapacke/include/*.h $(pack_get --install-prefix $bl)/include/"

if [ $bl == "atlas" ]; then
# We need to collect the two sets
pack_set --command "mkdir -p tmp"
pack_set --command "cd tmp"
# Extract atlas optimized lapack routines
pack_set --command "$AR x $(pack_get --prefix $bl)/lib/liblapack_atlas.a"
# replace them
pack_set --command "$AR r ../liblapack.a *.o"
pack_set --command "cd .."
pack_set --command "ranlib liblapack.a"
pack_set --command "cp liblapack.a $(pack_get --install-prefix $bl)/lib/liblapack.a"
fi

done