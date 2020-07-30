add_package https://gitlab.com/siesta-project/libraries/libgridxc/uploads/e6e4ec1e3ec648a45b3613e724c7be04/libgridxc-0.9.6.tar.gz

pack_set -s $IS_MODULE

libxc_v=4.3.4
pack_set -module-requirement libxc[$libxc_v]
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
pack_cmd "sed -i -s -e 's/return/exit/g' multiconfig-build.sh"
pack_cmd "GRIDXC_PREFIX=$(pack_get -prefix) LIBXC_ROOT=$(pack_get -prefix libxc[$libxc_v]) MPI_ROOT=$(pack_get -prefix mpi) bash ./multiconfig-build.sh"
