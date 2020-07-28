#!/bin/bash

. k8sProperties.sh

if [ "$#" -ne 1 ]
then
    echo "Usage: $0 build_docker_flag"
    exit 1
fi

buildDockerFlag=$1

if [ $buildDockerFlag == true ]
then
    echo `date`"   ######################################## build and push docker images ################################################"
    echo "Make sure you are logged into docker host"
    #docker login ${DOCKER_HOST}

    echo
    echo `date`"   #### build and push of gatlingnode image ###"
    docker build . -t ${DOCKERHUB_NODE_IMAGE} -f DockerfileNode -q
    docker push ${DOCKERHUB_NODE_IMAGE}

    echo
    echo `date`"   #### build and push of gatlingjoiner image ###"
    docker build . -t ${DOCKERHUB_JOINER_IMAGE} -f DockerfileJoiner  -q
    docker push ${DOCKERHUB_JOINER_IMAGE}

    #docker run -it --mount type=bind,source=${PWD}/${LOAD_PROFILE_SCALA},target=${GATLING_COPIED_DIR}/${LOAD_PROFILE_SCALA} ${DOCKERHUB_NODE_IMAGE} /bin/bash
    #docker run -it --env NUM_OF_NODES=3 ${DOCKERHUB_JOINER_IMAGE}  /bin/bash
fi

echo `date`"   ######################################## deploy k8s configmaps #######################################################"
echo "Make sure you are connected to kubectl"
kubectl delete namespace ${K8S_NAMESPACE}
kubectl create namespace ${K8S_NAMESPACE}

echo
echo `date`"   #### Creation of configmap  ${CONFIGMAP_LOAD_PROFILE_SCALA} ###"
kubectl create configmap ${CONFIGMAP_LOAD_PROFILE} --from-file=${K8SPROPERTIES} --from-file=${LOAD_PROFILE_SCALA} --from-file=${LOAD_PROFILE_JSON} -n ${K8S_NAMESPACE}

#kubectl get configmap -n ${K8S_NAMESPACE}

echo `date`"   ######################################## deploy k8s ##################################################################"
function replaceK8sPropertiesInYaml() {
    while read keyvalue; 
    do
        key=`echo $keyvalue | cut -d'=' -f1`
        value=${!key}
        #value=`sed "s/\//\//g"`
        value="$(sed "s/\//\\\\\//g" <<<"$value")"
        #value="${value//"latest"/"hehe"}"
        #echo $value
        sed -i "" "s/\${$key}/${value}/g" ${K8S_DEPLOY_FILE_TEMP}
    done < ${K8SPROPERTIES}
}

cp ${K8S_DEPLOY_FILE} ${K8S_DEPLOY_FILE_TEMP}
replaceK8sPropertiesInYaml
echo `date`"   #### Applying kubernetes yaml into namespace ${K8S_NAMESPACE} ###"
kubectl apply -f ${K8S_DEPLOY_FILE_TEMP} -n ${K8S_NAMESPACE}
rm -rf ${K8S_DEPLOY_FILE_TEMP}

echo `date`"   ######################################## kubectl stats/logs ##########################################################"
#kubectl get pods -n ${K8S_NAMESPACE}
#kubectl describe pod `kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'` -n ${K8S_NAMESPACE}
#kubectl exec -it `kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'` -n ${K8S_NAMESPACE} /bin/bash
#kubectl logs --follow `kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'` -n ${K8S_NAMESPACE}

echo `date`"   ######################################## copy combined gatling report ################################################"
function waitForReports() {
    GATLING_JOINER_POD=`kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'`
    while true
    do
        if [ -z $GATLING_JOINER_POD ]
        then
            echo "gatling joiner pod is not running. Waiting..."
            sleep ${BUILD_TIME_INTERVAL}
            GATLING_JOINER_POD=`kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'`
        else
            echo "gatling joined pod $GATLING_JOINER_POD"
            break
        fi
    done
    while true
    do
        successmsgcount=`kubectl logs $GATLING_JOINER_POD -n ${K8S_NAMESPACE} | grep "Waiting after completion" | wc -l`
        if [ $successmsgcount -gt 0 ]
	    then
            echo "Report generated. Continuing..."
            break
        fi
        echo `date`"   Waiting for report generation..."
        sleep ${BUILD_TIME_INTERVAL}
    done
}

echo `date`"   #### Waiting for reports ###"
waitForReports
DATENOW=`date "+%Y%m%d%H%M%S"`

echo
echo `date`"   #### Copying reports to local ###"
kubectl cp ${K8S_NAMESPACE}/`kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'`:/gatling_run_dir/reports.tar ./reports-${DATENOW}.tar
rm -rf reports
tar -xf reports-${DATENOW}.tar

echo
echo `date`"   #### Opening reports ###"
open reports/index.html

echo `date`"   ######################################## cleanup #####################################################################"
echo
echo `date`"   #### Kubectl cleanup ###"
#kubectl delete -f ${K8S_DEPLOY_FILE_TEMP} -n ${K8S_NAMESPACE}
#kubectl delete configmap ${CONFIGMAP_LOAD_PROFILE} -n ${K8S_NAMESPACE}
#kubectl delete namespace ${K8S_NAMESPACE}

echo
echo `date`"   #### Docker cleanup ###"
#docker stop $(docker ps -aq)
#docker rm $(docker ps -aq)