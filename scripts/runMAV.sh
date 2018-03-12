#! /bin/bash

if [ $# -ne 2 ] 
then
  echo "Usage: runMAV.sh <system_id> <gcs_port>"
  exit 1
fi

SCRIPTS_DIR=$(cd $(dirname $(which $0)); pwd)
docker run --rm -it -v $SCRIPTS_DIR:/external -e "SIM_OPTIONS=--out=udpout:docker.for.mac.localhost:$2 -m --target-system=$1" --entrypoint "/external/entryPoint.sh" gmyoungbloodparc/ardupilot-sitl $1
exit $?
