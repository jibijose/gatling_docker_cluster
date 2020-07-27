#!/bin/bash

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

mkdir /gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1/results/reports
echo "Copying simulation-*.log"
cp /pvc-data/simulation-*.* /gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1/results/reports/
echo "Generating combined gatling report"
/gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1/bin/gatling.sh -ro reports

rm -rf /gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1/results/reports/simulation-*.*
echo "Zipping reports"
tar -C /gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1/results/ -cvf /gatling_run_dir/reports.tar reports/

while true
do
	echo `date`"   Waiting after completion..."
	sleep 10
done