#! /bin/bash

if [ $# -ne 3 ] 
then
  echo "Usage: runMAV.sh <system_id> <gcs_host> <gcs_port>"
  exit 1
fi

SYS_ID=$1
GCS_HOST=$2
GCS_PORT=$3
SCRIPTS_DIR=$(cd $(dirname $(which $0)); pwd)

echo "Running SITL simulation ..."
echo SYS_ID=$SYS_ID GCS_HOST=$2 GCS_PORT=$3

docker run --rm -it -v $SCRIPTS_DIR:/external -e "SIM_OPTIONS=--out=udpout:$GCS_HOST:$GCS_PORT -m --target-system=$SYS_ID" --entrypoint "/external/entryPoint.sh" gmyoungbloodparc/ardupilot-sitl $SYS_ID
exit $?
