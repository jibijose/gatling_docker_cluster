#!/bin/bash

PVC_DATA=/pvc-data
HOSTNAME=`hostname`

cp /gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1/copied-run-files/loadprofile.scala /gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1/user-files/simulations/
/gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1/bin/gatling.sh -nr -s loadprofile > run.log

#mkdir /pvc-data/${HOSTNAME}
cp /gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1/results/loadprofile-*/simulation.log /pvc-data/simulation-${HOSTNAME}.log

while true
do
	sleep 10
done