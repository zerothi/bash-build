#!/bin/bash

# Create local rejections

{
    echo blis
    echo flame
    echo acml-install[5.3.1]
    echo ATK
    echo gcc[4.9.3]
    echo luaposix
    echo libctl
    echo boost
    echo llvm
    echo atlas
    echo ctl
    echo harminv
    echo gpaw
    echo gpaw-setups
    echo inelastica-matt
    echo hydra
    echo mpich
    echo pygtk
    echo qutip
    echo bigdft
    echo krypy
    echo siesta
    echo elk
    echo siesta-dev
    echo siesta-so
    echo siesta-scf
    echo siesta-scf-debug
    echo yambo
    echo espresso
    echo octave
} > ../local.reject

{
    echo fftw[intel]
    echo tinyarray
    echo openblas
    echo gromacs
    echo abinit
    echo bgw
} > ../intel.reject

{
    echo vasp
} > ../gnu.reject

