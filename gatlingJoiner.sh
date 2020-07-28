#!/bin/bash

GATLING_HOME=/gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1
GATLING_SIMULATIONS_DIR=${GATLING_HOME}/user-files/simulations
GATLING_RESULTS_DIR=${GATLING_HOME}/results
PVC_DATA=/pvc-data
HOSTNAME=`hostname`

NUM_OF_NODES=$1

while true
do
	numofnodes=`ls -al /pvc-data | grep simulation | wc -l`
	if [ $numofnodes == $NUM_OF_NODES ]
	then
		echo `date`"   Jobs completed in nodes $numofnodes"
		sleep 10
		break
	fi
	echo `date`"   Waiting... number of nodes completed $numofnodes out of expected $NUM_OF_NODES"
	sleep 10
done

mkdir ${GATLING_RESULTS_DIR}/reports
echo "Copying simulation-*.log"
cp ${PVC_DATA}/simulation-*.* ${GATLING_RESULTS_DIR}/reports/
echo "Generating combined gatling report"
${GATLING_HOME}/bin/gatling.sh -ro reports

rm -rf ${GATLING_RESULTS_DIR}/reports/simulation-*.*
echo "Zipping reports"
tar -C ${GATLING_RESULTS_DIR}/ -cvf /gatling_run_dir/reports.tar reports/

while true
do
	echo `date`"   Waiting after completion..."
	sleep 10
done