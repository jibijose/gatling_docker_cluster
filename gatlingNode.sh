#!/bin/bash

. /usr/local/bin/k8sProperties.sh

cp ${GATLING_HOME}/copied-run-files/loadprofile.scala ${GATLING_SIMULATIONS_DIR}/

sed -i "s/_namesuffix/_$HOSTNAME/g" ${GATLING_SIMULATIONS_DIR}/loadprofile.scala
sed -i "s/-Xmx1G/-Xms$GATLING_NODE_MAX_MEMORY -Xmx$GATLING_NODE_MAX_MEMORY/g" $GATLING_RUNNER
sed -i "s/#lowerBound = 800/lowerBound = $GATLING_REQ_LOWER_BOUND/g" $GATLING_CONF
sed -i "s/#higherBound = 1200/higherBound = $GATLING_REQ_HIGHER_BOUND/g" $GATLING_CONF
sed -i "s/#enableGA = true/enableGA = $GATLING_ENABLE_GA/g" $GATLING_CONF
sed -i "s/#maxRetry = 2/maxRetry = $GATLING_MAX_RETRY/g" $GATLING_CONF
sed -i "s/#requestTimeout = 60000/requestTimeout = $GATLING_REQ_TIMEOUT/g" $GATLING_CONF

${GATLING_HOME}/bin/gatling.sh -nr -s loadprofile > run.log

cp ${GATLING_HOME}/results/loadprofile-*/simulation.log ${PVC_DATA}/simulation-${HOSTNAME}.log

while true
do
	echo `date`"   Waiting..."
	sleep 10
done




ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sed -i 's/-Xmx1G/-Xms$GATLING_MEMORY -Xmx$GATLING_MEMORY/g' $GATLING_RUNNER"
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sed -i 's/#lowerBound = 800/lowerBound = $GATLING_REQ_LOWER_BOUND/g' $GATLING_CONF"
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sed -i 's/#higherBound = 1200/higherBound = $GATLING_REQ_HIGHER_BOUND/g' $GATLING_CONF"
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sed -i 's/#enableGA = true/enableGA = $GATLING_ENABLE_GA/g' $GATLING_CONF"
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sed -i 's/#maxRetry = 2/maxRetry = $GATLING_MAX_RETRY/g' $GATLING_CONF"
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sed -i 's/#requestTimeout = 60000/requestTimeout = $GATLING_REQ_TIMEOUT/g' $GATLING_CONF"