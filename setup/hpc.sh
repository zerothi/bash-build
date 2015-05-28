#!/bin/bash

# Create local rejections based on the hpc cluster

{
    echo abinit
    echo gdis
    echo gromacs
    echo gnumake
    echo llvm
    echo meep
    echo meep-serial
    echo pcre
    echo hydra
    echo mpich
    echo pandas
    echo scons
} > ../local.reject

{
    echo tinyarray
} > ../intel.reject

{
    echo vasp
} > ../gnu.reject