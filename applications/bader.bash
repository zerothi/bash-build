add_package --version 0.28a \
    http://theory.cm.utexas.edu/henkelman/code/bader/download/bader.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/bin/bader

file=Makefile
pack_cmd "echo '.SUFFIXES: .f90' > $file"

pack_cmd "sed -i '1 a\
FC = $FC \n\
FFLAGS = ${FCFLAGS//-O3/-O2} \n\
LINK = \n\
OBJS = kind_mod.o matrix_mod.o ions_mod.o options_mod.o charge_mod.o \
chgcar_mod.o cube_mod.o io_mod.o bader_mod.o voronoi_mod.o multipole_mod.o main.o \n\
%.o %.mod: %.f90\n\
\t\$(FC) \$(FFLAGS) -c \$\*.f90\n\
bader: \$(OBJS)\n\
\t\$(FC) \$(LINK) -o bader \$(OBJS)' $file"

# Make commands
pack_cmd "make bader"
pack_cmd "mkdir -p $(pack_get --prefix)/bin/"
pack_cmd "cp bader $(pack_get --prefix)/bin/"

