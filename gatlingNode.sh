#!/bin/bash

if [ "$#" -ne 1 ]
then
    echo "Usage: $0 load_profile"
    exit 1
fi

. /gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1/copied-run-files/k8sProperties.sh $1

cp ${GATLING_HOME}/copied-run-files/${LOAD_PROFILE_SCALA} ${GATLING_SIMULATIONS_DIR}/
cp ${GATLING_HOME}/copied-run-files/${LOAD_PROFILE_JSON} ${GATLING_RESOURCES_DIR}/


sed -i "s/\${HOSTNAME}/$HOSTNAME/g" ${GATLING_SIMULATIONS_DIR}/${LOAD_PROFILE_SCALA}
sed -i "s/-Xmx1G/-Xms$GATLING_NODE_MAX_MEMORY -Xmx$GATLING_NODE_MAX_MEMORY/g" $GATLING_RUNNER
sed -i "s/#lowerBound = 800/lowerBound = $GATLING_REQ_LOWER_BOUND/g" $GATLING_CONF
sed -i "s/#higherBound = 1200/higherBound = $GATLING_REQ_HIGHER_BOUND/g" $GATLING_CONF
sed -i "s/#enableGA = true/enableGA = $GATLING_ENABLE_GA/g" $GATLING_CONF
sed -i "s/#maxRetry = 2/maxRetry = $GATLING_MAX_RETRY/g" $GATLING_CONF
sed -i "s/#requestTimeout = 60000/requestTimeout = $GATLING_REQ_TIMEOUT/g" $GATLING_CONF

${GATLING_HOME}/bin/gatling.sh -nr -s ${LOAD_PROFILE_NAME} > run.log

cp ${GATLING_HOME}/results/${LOAD_PROFILE_NAME}-*/simulation.log ${PVC_DATA}/simulation-${HOSTNAME}.log

while true
do
	echo `date`"   Waiting..."
	sleep ${RUN_TIME_INTERVAL}
done