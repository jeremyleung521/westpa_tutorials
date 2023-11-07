#!/bin/bash

# Set up environment for dynamics
module load gcc/8.2.0 openmpi/4.0.3
module load gromacs/2021.2
conda activate emergency-westpa
#source /usr/local/gromacs/bin/GMXRC

# Set WESTPA-related variables
export WEST_SIM_ROOT="$PWD"
export SIM_NAME=$(basename $WEST_SIM_ROOT)

# Set runtime commands
export GMX=$(which gmx)
