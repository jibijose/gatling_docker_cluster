#!/bin/bash

. /usr/local/bin/k8sProperties.sh

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

sed -i "s/_namesuffix/_$HOSTNAME/g" ${GATLING_SIMULATIONS_DIR}/${LOADPROFILE}
sed -i "s/-Xmx1G/-Xms$GATLING_JOINER_MAX_MEMORY -Xmx$GATLING_JOINER_MAX_MEMORY/g" $GATLING_RUNNER
sed -i "s/#lowerBound = 800/lowerBound = $GATLING_REQ_LOWER_BOUND/g" $GATLING_CONF
sed -i "s/#higherBound = 1200/higherBound = $GATLING_REQ_HIGHER_BOUND/g" $GATLING_CONF
sed -i "s/#enableGA = true/enableGA = $GATLING_ENABLE_GA/g" $GATLING_CONF
sed -i "s/#maxRetry = 2/maxRetry = $GATLING_MAX_RETRY/g" $GATLING_CONF
sed -i "s/#requestTimeout = 60000/requestTimeout = $GATLING_REQ_TIMEOUT/g" $GATLING_CONF

echo "Generating combined gatling report"
${GATLING_HOME}/bin/gatling.sh -ro reports

rm -rf ${GATLING_RESULTS_DIR}/reports/simulation-*.*
echo "Zipping reports"
tar -C ${GATLING_RESULTS_DIR}/ -cf /gatling_run_dir/reports.tar reports/

while true
do
	echo `date`"   Waiting after completion..."
	sleep 10
done