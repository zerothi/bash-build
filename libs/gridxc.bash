add_package https://gitlab.com/siesta-project/libraries/libgridxc/uploads/e38a2a6d74b802065a1f7acb0f69e662/libgridxc-0.9.5.tar.gz

pack_set -s $IS_MODULE

pack_set -module-requirement libxc
pack_set -module-requirement mpi

pack_set -install-query $(pack_get -LD)/libgridxc_dp_mpi.a
pack_set -lib -lgridxc_dp
pack_set -lib[mpi] -lgridxc_dp_mpi
pack_set -lib[sp] -lgridxc_sp
pack_set -lib[sp-mpi] -lgridxc_sp_mpi

# Install commands that it should run
# A bug in multiconfig-build.sh does not allow
# compiling with F77 F90 env-vars set
pack_cmd "unset F77"
pack_cmd "unset F90"
pack_cmd "GRIDXC_PREFIX=$(pack_get -prefix) LIBXC_ROOT=$(pack_get -prefix libxc) MPI_ROOT=$(pack_get -prefix mpi) bash ./multiconfig-build.sh"
