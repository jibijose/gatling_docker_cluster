#!/bin/bash

LOADPROFILE=loadprofile.scala
CONFIGMAP_NAME=cm.gatling
K8S_NAMESPACE=gatlingcluster
K8S_DEPLOY_FILE=k8s.yaml
#DOCKERHUB_IMAGE=registry.hub.docker.com/jibijose/inprogress:latest
DOCKERHUB_IMAGE=registry.hub.docker.com/jibijose/gatlingcluster:latest
DOCKER_GATLING_HOME=/gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1
DOCKER_GATLING_COPIED_DIR=${DOCKER_GATLING_HOME}/copied-run-files

docker build . -t ${DOCKERHUB_IMAGE}
#docker run -it --mount type=bind,source=${PWD}/${LOADPROFILE},target=${DOCKER_GATLING_COPIED_DIR}/${LOADPROFILE} ${DOCKERHUB_IMAGE} /bin/bash
#docker login registry.hub.docker.com
docker push ${DOCKERHUB_IMAGE}


#kubectl create namespace  ${K8S_NAMESPACE}
kubectl delete configmap ${CONFIGMAP_NAME} -n ${K8S_NAMESPACE}
kubectl create configmap ${CONFIGMAP_NAME} --from-file=${LOADPROFILE} -n ${K8S_NAMESPACE}
#kubectl get configmap -n ${K8S_NAMESPACE}

kubectl delete -f ${K8S_DEPLOY_FILE} -n ${K8S_NAMESPACE}
kubectl apply -f ${K8S_DEPLOY_FILE} -n ${K8S_NAMESPACE}
#kubectl get pods -n ${K8S_NAMESPACE}
#kubectl describe pod `kubectl get pods -n ${K8S_NAMESPACE} | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'` -n ${K8S_NAMESPACE}
#kubectl exec -it `kubectl get pods -n ${K8S_NAMESPACE} | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'` -n ${K8S_NAMESPACE} /bin/bash
#kubectl logs `kubectl get pods -n ${K8S_NAMESPACE} | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'` -n ${K8S_NAMESPACE} -p