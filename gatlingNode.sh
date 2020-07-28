#!/bin/bash

. /usr/local/bin/k8sProperties.sh

cp ${GATLING_HOME}/copied-run-files/loadprofile.scala ${GATLING_SIMULATIONS_DIR}/
sed -i "s/_namesuffix/_$HOSTNAME/g" ${GATLING_SIMULATIONS_DIR}/loadprofile.scala
${GATLING_HOME}/bin/gatling.sh -nr -s loadprofile > run.log

#mkdir /pvc-data/${HOSTNAME}
cp ${GATLING_HOME}/results/loadprofile-*/simulation.log ${PVC_DATA}/simulation-${HOSTNAME}.log

while true
do
	echo `date`"   Waiting..."
	sleep 10
done