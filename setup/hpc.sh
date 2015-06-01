#!/bin/bash

# Create local rejections based on the hpc cluster

{
    echo abinit
    echo gdis
    echo gromacs
    echo make
    echo llvm
    echo meep
    echo meep-serial
    echo pcre
    echo hydra
    echo mpich
    echo pandas
    echo scons
    echo luaposix
    echo lmod
} > ../local.reject

{
    echo tinyarray
    echo openblas
    echo boost
} > ../intel.reject

{
    echo vasp
} > ../gnu.reject
