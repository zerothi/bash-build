for v in 1.83.0
do
  add_package -build generic -no-default-modules -alias rust -package rust \
    https://static.rust-lang.org/dist/rust-$v-$(uname -m)-unknown-linux-gnu.tar.xz

  pack_set -s $IS_MODULE

  pack_set -install-query $(pack_get -prefix)/bin/rustc
  pack_set -module-opt "-prepend-ENV PATH=~/.cargo/bin"

  pack_cmd "./install.sh --prefix=$(pack_get -prefix) --verbose --disable-ldconfig"

  # Needed as it is not source_pack
  pack_install

done
