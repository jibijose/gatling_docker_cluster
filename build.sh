#!/bin/bash

. k8sProperties.sh

echo "######################################## build and push docker images ################################################"
echo "Make sure you are logged into docker host"
#docker login ${DOCKER_HOST}

echo
echo "#### build and push of gatlingnode image ###"
docker build . -t ${DOCKERHUB_NODE_IMAGE} -f DockerfileNode -q
docker push ${DOCKERHUB_NODE_IMAGE}

echo
echo "#### build and push of gatlingjoiner image ###"
docker build . -t ${DOCKERHUB_JOINER_IMAGE} -f DockerfileJoiner  -q
docker push ${DOCKERHUB_JOINER_IMAGE}

#docker run -it --mount type=bind,source=${PWD}/${LOADPROFILE},target=${GATLING_COPIED_DIR}/${LOADPROFILE} ${DOCKERHUB_NODE_IMAGE} /bin/bash
#docker run -it --env NUM_OF_NODES=3 ${DOCKERHUB_JOINER_IMAGE}  /bin/bash

echo "######################################## deploy k8s configmaps #######################################################"
echo "Make sure you are connected to kubectl"
#kubectl create namespace  ${K8S_NAMESPACE}

echo
echo "#### Creation of configmap  ${CONFIGMAP_LOADPROFILE_NAME} ###"
kubectl delete configmap ${CONFIGMAP_LOADPROFILE_NAME} -n ${K8S_NAMESPACE}
kubectl create configmap ${CONFIGMAP_LOADPROFILE_NAME} --from-file=${LOADPROFILE} -n ${K8S_NAMESPACE}
#kubectl get configmap -n ${K8S_NAMESPACE}

echo
echo "#### Creation of configmap  ${CONFIGMAP_K8S_PROPS_NAME} ###"
kubectl delete configmap ${CONFIGMAP_K8S_PROPS_NAME} -n ${K8S_NAMESPACE}
kubectl create configmap ${CONFIGMAP_K8S_PROPS_NAME} --from-file=${K8SPROPERTIES} -n ${K8S_NAMESPACE}
#kubectl get configmap -n ${K8S_NAMESPACE}

echo "######################################## deploy k8s ##################################################################"
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
echo "#### Applying kubernetes yaml into namespace ${K8S_NAMESPACE} ###"
kubectl delete -f ${K8S_DEPLOY_FILE_TEMP} -n ${K8S_NAMESPACE}
kubectl apply -f ${K8S_DEPLOY_FILE_TEMP} -n ${K8S_NAMESPACE}
rm -rf ${K8S_DEPLOY_FILE_TEMP}

echo "######################################## kubectl stats/logs ##########################################################"
#kubectl get pods -n ${K8S_NAMESPACE}
#kubectl describe pod `kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'` -n ${K8S_NAMESPACE}
#kubectl exec -it `kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'` -n ${K8S_NAMESPACE} /bin/bash
#kubectl logs --follow `kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'` -n ${K8S_NAMESPACE}

echo "######################################## copy combined gatling report ################################################"
function waitForReports() {
    GATLING_JOINER_POD=`kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'`
    while true
    do
        if [ -z $GATLING_JOINER_POD ]
        then
            echo "gatling joiner pod is not running. Waiting..."
            sleep 10
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
        sleep 10
    done
}

echo "#### Waiting for reports ###"
waitForReports
DATENOW=`date "+%Y%m%d%H%M%S"`

echo
echo "#### Copying reports to local ###"
kubectl cp gatlingcluster/`kubectl get pods -n ${K8S_NAMESPACE} | grep "gatlingjoiner" | grep "Running" | grep "1/1" | tail -n 1 | awk '{print $1;}'`:/gatling_run_dir/reports.tar ./reports-${DATENOW}.tar
rm -rf reports
tar -xvf reports-${DATENOW}.tar

echo
echo "#### Opening reports ###"
open reports/index.html

echo "######################################## docker cleanup ##############################################################"
#docker stop $(docker ps -aq)
#docker rm $(docker ps -aq)