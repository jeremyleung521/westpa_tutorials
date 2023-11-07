#!/bin/bash
#SBATCH --job-name=NaCl_ZMQ
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=14
#SBATCH --output=job_logs/slurm.out
#SBATCH --error=job_logs/slurm.err
#SBATCH --time=12:00:00
#SBATCH --cluster=mpi
#SBATCH --partition=opa

#set -x
source ./env.sh
source ./init.sh

#env | sort

echo "main root is"
echo $WEST_SIM_ROOT
cd $WEST_SIM_ROOT

SERVER_INFO=$WEST_SIM_ROOT/west_zmq_info-$SLURM_JOBID.json

# start server
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
# this example, we have 28 tasks per node (as set above) and have the same number of workers
# make sure gmx mdrun -nt is correctly set in runseg.sh

srun -N 2 $WEST_SIM_ROOT/node.sh $WEST_SIM_ROOT --work-manager=zmq --zmq-mode=client --n-workers=$SLURM_NTASKS_PER_NODE --zmq-read-host-info=$SERVER_INFO --zmq-comm-mode=tcp &


# Alternative way to run this:

#for node in $(scontrol show hostname $SLURM_NODELIST); do
#    echo $node
#    ssh -o StrictHostKeyChecking=no $node $WEST_SIM_ROOT/node.sh $WEST_SIM_ROOT --work-manager=zmq --zmq-mode=client --n-workers=$SLURM_NTASKS_PER_NODE --zmq-read-host-info=$SERVER_INFO --zmq-comm-mode=tcp &
#done


wait
