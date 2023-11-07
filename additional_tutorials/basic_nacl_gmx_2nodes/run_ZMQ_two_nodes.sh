#!/bin/bash
#SBATCH --job-name=NaCl_ZMQ
#SBATCH --partition=cpu
#SBATCH --ntasks-per-node=12
#SBATCH --nodes=2
#SBATCH --time=1:00:00

#set -x
#cd $SLURM_SUBMIT_DIR
source ./env.sh
source ./init.sh

#env | sort

echo "main root is"
echo $WEST_SIM_ROOT
cd $WEST_SIM_ROOT
#bash ./env.sh
#bash ./init.sh

SERVER_INFO=$WEST_SIM_ROOT/west_zmq_info-$SLURM_JOBID.json

# This doesn't start up the multiple ones.  That's going to be okay for testing...
# start server
# NEEDS TO BE MODIFIED
w_run --zmq-startup-timeout 3600 \
      --zmq-shutdown-timeout 360 \
      --zmq-timeout-factor 240 \
      --zmq-master-heartbeat 3 \
      --zmq-worker-heartbeat 120 \
      --work-manager=zmq \
      --n-workers=0 \
      --zmq-mode=master \
      --zmq-write-host-info=$SERVER_INFO \
      --zmq-comm-mode=tcp &> west-$SLURM_JOBID.log &

# wait on host info file up to one minute
for ((n=0; n<60; n++)); do
    if [ -e $SERVER_INFO ] ; then
        echo "== server info file $SERVER_INFO =="
        cat $SERVER_INFO
        break
    fi
    sleep 1
done

# exit if host info file doesn't appear in one minute
if ! [ -e $SERVER_INFO ] ; then
    echo 'server failed to start'
    exit 1
fi

# start clients, with the proper number of cores on each
# run for 48 cores. each 2 cores run one WE segment
# to do this. we need to change --nodes=2, --ntasks-per-node=12 and the -nt command in gmx mdrun in runseg.sh
# this seems to work by using all the 48 cores in all 48 runs

echo $SLURM_SUBMIT_DIR
echo $SLURM_JOBID
#srun -N 2 --ntasks-per-node 1 $WEST_SIM_ROOT/node.sh $SLURM_SUBMIT_DIR $SLURM_JOBID $node --work-manager=zmq --zmq-mode=client --n-workers=1 --zmq-read-host-info=$SERVER_INFO --zmq-comm-mode=tcp --debug &
srun -N 2 --ntasks-per-node 12 $WEST_SIM_ROOT/node.sh $WEST_SIM_ROOT --work-manager=zmq --zmq-mode=client --n-workers=12 --zmq-read-host-info=$SERVER_INFO --zmq-comm-mode=tcp &


#
#srun --nodes=2 --ntasks=12 --cpus-per-task=4 $WEST_SIM_ROOT/node.sh --work-manager=zmq --zmq-mode=client --zmq-read-host-info=$SERVER_INFO --zmq-comm-mode=tcp --debug &

#for node in $(scontrol show hostname $SLURM_NODELIST); do
#    echo $node
#    ssh -o StrictHostKeyChecking=no $node $WEST_SIM_ROOT/node.sh $SLURM_SUBMIT_DIR $SLURM_JOBID $node --work-manager=zmq --zmq-mode=client --n-workers=12 --zmq-read-host-info=$SERVER_INFO --zmq-comm-mode=tcp &
#done


wait
