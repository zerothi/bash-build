module purge

# Figure out the default build
def_build=$(build_get -default-build)

# Get name
name=$(build_get -name[$def_build])

if [ ! -e source-${name}-cuda.sh ]; then
    echo ""
    echo "Could not locate source-file:"
    echo "  source-${name}-cuda.sh"
    exit 1
fi
source source-${name}-cuda.sh
# new_build copies lots of common data
new_build --name cuda \
    --source source-${name}-cuda.sh \
    --default-module "$(build_get -default-module[$name])"

build_set --default-choice[cuda] linalg openblas blis atlas blas

