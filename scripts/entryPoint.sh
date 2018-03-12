#! /bin/bash
source /etc/profile
echo SYSID_THISMAV=$1 | tee -a /ardupilot/Tools/autotest/default_params/plane.parm
sim_vehicle.py --speedup=$SPEEDUP $SIM_OPTIONS
