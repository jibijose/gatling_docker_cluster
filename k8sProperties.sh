#################### editable variables ############################
K8S_NAMESPACE=gatlingcluster
DOCKER_HOST=registry.hub.docker.com
DOCKER_USER=jibijose

#################### other variables ############################
LOADPROFILE=loadprofile.scala
K8SPROPERTIES=k8sProperties.sh
K8S_DEPLOY_FILE=k8s.yaml
CONFIGMAP_LOADPROFILE_NAME=loadprofile.scala
CONFIGMAP_K8S_PROPS_NAME=k8s.properties
K8S_DEPLOY_FILE_TEMP=k8s_temp.yaml
DOCKERHUB_NODE_IMAGE=${DOCKER_HOST}/${DOCKER_USER}/gatlingnode:latest
DOCKERHUB_JOINER_IMAGE=${DOCKER_HOST}/${DOCKER_USER}/gatlingjoiner:latest

GATLING_HOME=/gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1
GATLING_SIMULATIONS_DIR=${GATLING_HOME}/user-files/simulations
GATLING_RESULTS_DIR=${GATLING_HOME}/results
GATLING_COPIED_DIR=${GATLING_HOME}/copied-run-files

PVC_DATA=/pvc-data
PVC_SIZE=5Gi

NUM_OF_NODES=3
NODE_CPU_REQUEST=500m
NODE_MEMORY_REQUEST=1Gi
NODE_CPU_LIMIT=1000m
NODE_MEMORY_LIMIT=2Gi

JOINER_CPU_REQUEST=1000m
JOINER_MEMORY_REQUEST=4Gi
JOINER_CPU_LIMIT=2000m
JOINER_MEMORY_LIMIT=10Gi

