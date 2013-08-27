# Then install OpenBLAS
add_package \
    --directory BLAS \
    --archive openblas-0.2.8.tar.gz \
    https://codeload.github.com/xianyi/OpenBLAS/legacy.tar.gz/v0.2.8

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$(get_c)

# Required as the version has just been set
pack_set --install-query $(pack_get --install-prefix)/lib/libgotoblas.a


