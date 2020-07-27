#!/bin/bash

LOADPROFILE=loadprofile.scala
K8SPROPERTIES=k8s.properties
K8SPROPERTIESTEMP=k8s_temp.properties
CONFIGMAP_LOADPROFILE_NAME=loadprofile.scala
CONFIGMAP_K8S_PROPS_NAME=k8s.properties
K8S_NAMESPACE=gatlingcluster
K8S_DEPLOY_FILE=k8s.yaml
K8S_DEPLOY_FILE_TEMP=k8s_temp.yaml
#DOCKERHUB_IMAGE=registry.hub.docker.com/jibijose/inprogress:latest
DOCKERHUB_NODE_IMAGE=registry.hub.docker.com/jibijose/gatlingnode:latest
DOCKERHUB_JOINER_IMAGE=registry.hub.docker.com/jibijose/gatlingjoiner:latest
DOCKER_GATLING_HOME=/gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1
DOCKER_GATLING_COPIED_DIR=${DOCKER_GATLING_HOME}/copied-run-files

docker build . -t ${DOCKERHUB_NODE_IMAGE} -f DockerfileNode
#docker run -it --mount type=bind,source=${PWD}/${LOADPROFILE},target=${DOCKER_GATLING_COPIED_DIR}/${LOADPROFILE} ${DOCKERHUB_NODE_IMAGE} /bin/bash
#docker login registry.hub.docker.com
docker push ${DOCKERHUB_NODE_IMAGE}

docker build . -t ${DOCKERHUB_JOINER_IMAGE} -f DockerfileJoiner
#docker run -it --env NUM_OF_NODES=3 ${DOCKERHUB_JOINER_IMAGE}  /bin/bash
#docker login registry.hub.docker.com
docker push ${DOCKERHUB_JOINER_IMAGE}


#kubectl create namespace  ${K8S_NAMESPACE}
kubectl delete configmap ${CONFIGMAP_LOADPROFILE_NAME} -n ${K8S_NAMESPACE}
kubectl create configmap ${CONFIGMAP_LOADPROFILE_NAME} --from-file=${LOADPROFILE} -n ${K8S_NAMESPACE}
#kubectl get configmap -n ${K8S_NAMESPACE}

#kubectl create namespace  ${K8S_NAMESPACE}
kubectl delete configmap ${CONFIGMAP_K8S_PROPS_NAME} -n ${K8S_NAMESPACE}
kubectl create configmap ${CONFIGMAP_K8S_PROPS_NAME} --from-file=${K8SPROPERTIES} -n ${K8S_NAMESPACE}
#kubectl get configmap -n ${K8S_NAMESPACE}

sed 's/^/export /' ${K8SPROPERTIES} > ${K8SPROPERTIESTEMP}
. ${K8SPROPERTIESTEMP}
cp ${K8S_DEPLOY_FILE} ${K8S_DEPLOY_FILE_TEMP}
sed -i "" "s/\${NUM_OF_NODES}/$NUM_OF_NODES/g" ${K8S_DEPLOY_FILE_TEMP}
sed -i "" "s/\${PVC_SIZE}/$PVC_SIZE/g" ${K8S_DEPLOY_FILE_TEMP}
sed -i "" "s/\${NODE_CPU_REQUEST}/$NODE_CPU_REQUEST/g" ${K8S_DEPLOY_FILE_TEMP}
sed -i "" "s/\${NODE_MEMORY_REQUEST}/$NODE_MEMORY_REQUEST/g" ${K8S_DEPLOY_FILE_TEMP}
sed -i "" "s/\${NODE_CPU_LIMIT}/$NODE_CPU_LIMIT/g" ${K8S_DEPLOY_FILE_TEMP}
sed -i "" "s/\${NODE_MEMORY_LIMIT}/$NODE_MEMORY_LIMIT/g" ${K8S_DEPLOY_FILE_TEMP}
kubectl delete -f ${K8S_DEPLOY_FILE_TEMP} -n ${K8S_NAMESPACE}
kubectl apply -f ${K8S_DEPLOY_FILE_TEMP} -n ${K8S_NAMESPACE}
#kubectl get pods -n ${K8S_NAMESPACE}
#kubectl describe pod `kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'` -n ${K8S_NAMESPACE}
#kubectl exec -it `kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'` -n ${K8S_NAMESPACE} /bin/bash
#kubectl logs `kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'` -n ${K8S_NAMESPACE}

DATENOW=`date "+%Y%m%d%H%M%S"`
kubectl cp gatlingcluster/`kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'`:/gatling_run_dir/reports.tar ./reports-${DATENOW}.tar
rm -rf reports
tar -xvf reports-${DATENOW}.tar
open reports/index.html

#docker stop $(docker ps -aq)
#docker rm $(docker ps -aq)