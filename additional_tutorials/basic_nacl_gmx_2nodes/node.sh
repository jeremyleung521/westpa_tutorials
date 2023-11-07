#!/bin/bash -l

set -x
#cd /lfs01/workdirs/cairo029u1/1PHD/WESTPA/trial/nacl_gromacs/gromacs/first_example_westpa_files_ZMQ
cd $1; shift
#cd /ix/lchong/jml230/westpa_tutorials/additional_tutorials/basic_nacl_gmx_2nodes
echo "pwd is 11 1 1 11"
echo $PWD
#cd $1; shift
source ./env.sh

#export WEST_JOBID=$1; shift
#export SLURM_NODENAME=$1; shift

#echo "starting WEST client processes on: "; hostname
#echo "current directory is $PWD"
#echo "environment is: "
#env | sort
# Bit more complicated than this...
w_run "$@" &> west-$(hostname)-node.log

echo "Shutting down.  Hopefully this was on purpose?"
