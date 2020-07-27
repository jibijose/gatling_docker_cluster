#!/bin/bash

LOADPROFILE=loadprofile.scala
K8SPROPERTIES=k8s.properties
CONFIGMAP_LOADPROFILE_NAME=loadprofile.scala
CONFIGMAP_K8S_PROPS_NAME=k8s.properties
K8S_NAMESPACE=gatlingcluster
K8S_DEPLOY_FILE=k8s.yaml
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
#docker run -it ${DOCKERHUB_JOINER_IMAGE} /bin/bash
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

kubectl delete -f ${K8S_DEPLOY_FILE} -n ${K8S_NAMESPACE}
sed 's/^/export /' ${K8SPROPERTIES} > ${K8SPROPERTIES}_temp
. ${K8SPROPERTIES}_temp
rm -rf ${K8SPROPERTIES}_temp
sed -i "s/\${NUM_OF_NODES}/$NUM_OF_NODES/g" ${K8S_DEPLOY_FILE}
kubectl apply -f ${K8S_DEPLOY_FILE} -n ${K8S_NAMESPACE}
#kubectl get pods -n ${K8S_NAMESPACE}
#kubectl describe pod `kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'` -n ${K8S_NAMESPACE}
#kubectl exec -it `kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'` -n ${K8S_NAMESPACE} /bin/bash
#kubectl logs `kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'` -n ${K8S_NAMESPACE} -p


#docker stop $(docker ps -aq)
#docker rm $(docker ps -aq)