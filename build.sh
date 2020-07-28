#!/bin/bash

#################### editable variables ############################
K8S_NAMESPACE=gatlingcluster
DOCKER_HOST=registry.hub.docker.com
DOCKER_USER=jibijose

#################### other variables ############################
LOADPROFILE=loadprofile.scala
K8SPROPERTIES=k8s.properties
K8S_DEPLOY_FILE=k8s.yaml
CONFIGMAP_LOADPROFILE_NAME=loadprofile.scala
CONFIGMAP_K8S_PROPS_NAME=k8s.properties
K8SPROPERTIESTEMP=k8s_temp.properties
K8S_DEPLOY_FILE_TEMP=k8s_temp.yaml
DOCKERHUB_NODE_IMAGE=${DOCKER_HOST}/${DOCKER_USER}/gatlingnode:latest
DOCKERHUB_JOINER_IMAGE=${DOCKER_HOST}/${DOCKER_USER}/gatlingjoiner:latest
DOCKER_GATLING_HOME=/gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1
DOCKER_GATLING_COPIED_DIR=${DOCKER_GATLING_HOME}/copied-run-files

#################### build and push docker images ############################
echo "Make sure you are logged into docker host"
#docker login ${DOCKER_HOST}

docker build . -t ${DOCKERHUB_NODE_IMAGE} -f DockerfileNode
docker push ${DOCKERHUB_NODE_IMAGE}

docker build . -t ${DOCKERHUB_JOINER_IMAGE} -f DockerfileJoiner
docker push ${DOCKERHUB_JOINER_IMAGE}

#docker run -it --mount type=bind,source=${PWD}/${LOADPROFILE},target=${DOCKER_GATLING_COPIED_DIR}/${LOADPROFILE} ${DOCKERHUB_NODE_IMAGE} /bin/bash
#docker run -it --env NUM_OF_NODES=3 ${DOCKERHUB_JOINER_IMAGE}  /bin/bash

#################### deploy k8s configmaps ############################
echo "Make sure you are connected to kubectl"
#kubectl create namespace  ${K8S_NAMESPACE}
kubectl delete configmap ${CONFIGMAP_LOADPROFILE_NAME} -n ${K8S_NAMESPACE}
kubectl create configmap ${CONFIGMAP_LOADPROFILE_NAME} --from-file=${LOADPROFILE} -n ${K8S_NAMESPACE}
#kubectl get configmap -n ${K8S_NAMESPACE}

#kubectl create namespace  ${K8S_NAMESPACE}
kubectl delete configmap ${CONFIGMAP_K8S_PROPS_NAME} -n ${K8S_NAMESPACE}
kubectl create configmap ${CONFIGMAP_K8S_PROPS_NAME} --from-file=${K8SPROPERTIES} -n ${K8S_NAMESPACE}
#kubectl get configmap -n ${K8S_NAMESPACE}

#################### deploy k8s ############################

function replaceK8sProperties() {
    while read keyvalue; 
    do 
        key=`echo $keyvalue | cut -d'=' -f1`
        value=`echo $keyvalue | cut -d'=' -f2`
        #echo "KEY = $key   VALUE=$value"
        sed -i "" "s/\${$key}/$value/g" ${K8S_DEPLOY_FILE_TEMP}
    done < ${K8SPROPERTIES}
}

echo "Make sure you are connected to kubectl"
sed 's/^/export /' ${K8SPROPERTIES} > ${K8SPROPERTIESTEMP}
. ${K8SPROPERTIESTEMP}
rm -rf ${K8SPROPERTIESTEMP}

cp ${K8S_DEPLOY_FILE} ${K8S_DEPLOY_FILE_TEMP}
replaceK8sProperties
kubectl delete -f ${K8S_DEPLOY_FILE_TEMP} -n ${K8S_NAMESPACE}
kubectl apply -f ${K8S_DEPLOY_FILE_TEMP} -n ${K8S_NAMESPACE}
rm -rf ${K8S_DEPLOY_FILE_TEMP}

#################### kubectl stats/logs ############################
#kubectl get pods -n ${K8S_NAMESPACE}
#kubectl describe pod `kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'` -n ${K8S_NAMESPACE}
#kubectl exec -it `kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'` -n ${K8S_NAMESPACE} /bin/bash
#kubectl logs --follow `kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'` -n ${K8S_NAMESPACE}

#################### copy combined gatling report ############################
function waitForReports() {
    GATLING_JOINER_POD=`kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'`
    while true
    do
        successmsgcount=`kubectl logs $GATLING_JOINER_POD -n ${K8S_NAMESPACE} | grep "Waiting after completion" | wc -l`
        if [ $successmsgcount -gt 0 ]
	    then
            echo "Report generated. Continuing..."
            break
        fi
        echo `date`"   Waiting for report generation..."
        sleep 10
    done
}

waitForReports
DATENOW=`date "+%Y%m%d%H%M%S"`
kubectl cp gatlingcluster/`kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'`:/gatling_run_dir/reports.tar ./reports-${DATENOW}.tar
rm -rf reports
tar -xvf reports-${DATENOW}.tar
open reports/index.html

#################### docker cleanup ############################
#docker stop $(docker ps -aq)
#docker rm $(docker ps -aq)