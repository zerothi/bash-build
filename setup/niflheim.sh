#!/bin/bash

# Create local rejections based on the hpc cluster

{
    echo gdis
    echo meep
    echo meep-serial
    echo mpb
    echo mpb-serial
    echo xcrysden
    echo graphviz
    echo llvm
    echo atlas
    echo ctl
    echo harminv
    echo hydra
    echo mpich
    echo superlu
    echo superlu-dist
    echo pygtk
    echo qutip
} > ../local.reject

{
    echo fftw[intel]
    echo tinyarray
} > ../intel.reject

{
    echo vasp
} > ../gnu.reject