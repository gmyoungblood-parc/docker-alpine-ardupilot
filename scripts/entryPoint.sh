#! /bin/bash
source /etc/profile
echo SYSID_THISMAV=$1 >> /ardupilot/Tools/autotest/default_params/plane.parm
grep SYSID_THISMAV /ardupilot/Tools/autotest/default_params/plane.parm
echo $SIM_OPTIONS
sim_vehicle.py --speedup=$SPEEDUP $SIM_OPTIONS
