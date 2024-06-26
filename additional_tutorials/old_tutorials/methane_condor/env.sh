# This file defines where WEST and GROMACS can be found
# Modify to taste

# Find EPD and GROMACS
##source /etc/profile.d/modules.sh
##module load epd
##module load gromacs

# Inform WEST where to find Python and our other scripts where to find WEST
export WEST_PYTHON=$(which python2.7)
export WEST_ROOT=$(readlink -f $PWD/../../..)

# Explicitly name our simulation root directory
if [[ -z "$WEST_SIM_ROOT" ]]; then
    export WEST_SIM_ROOT="$PWD"
fi
export SIM_NAME=$(basename $WEST_SIM_ROOT)
echo "simulation $SIM_NAME root is $WEST_SIM_ROOT"
